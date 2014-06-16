'''
Created on Jun 27, 2013

@author: lindahlm
'''
import numpy
import os

from toolbox import misc, pylab
from toolbox.data_to_disk import Storage_dic
from toolbox.network import manager
from toolbox.network.manager import (add_perturbations, compute, 
                                     run, save, load, get_storage)
from toolbox.network.manager import Builder_inhibition_striatum as Builder
from simulate import (show_fr, show_mr, cmp_mean_rates_intervals,
                      get_file_name, get_file_name_figs)
import pprint
pp=pprint.pprint
    
DISPLAY=os.environ.get('DISPLAY')

def get_kwargs_builder():
    return {'print_time':False, 
            'threads':8, 
            'save_conn':{'overwrite':False},
            'sim_time':8000.0, 
            'sim_stop':8000.0, 
            'size':3000.0, 
            'start_rec':0.0, 
            'sub_sampling':1}

def get_kwargs_engine():
    return {'verbose':True}

def get_networks():
    info, nets, builder=manager.get_networks(Builder,
                                             get_kwargs_builder(),
                                             get_kwargs_engine())
    
    intervals=builder.dic['intervals']
    rates=builder.dic['amplitudes']
    rep=builder.dic['repetitions']
    
    return info, nets, intervals, rates, rep


def main(from_disk=2,
         perturbation_list=None,
         script_name=__file__.split('/')[-1][0:-3]):
    
    
    from os.path import expanduser
    home = expanduser("~")

    
    file_name = get_file_name(script_name, home)
    file_name_figs=get_file_name_figs(script_name, home)
    
    models=['M1', 'M2','FS', 'GI', 'GA', 'ST', 'SN']
    
    info, nets, intervals, amplitudes, rep = get_networks()
    add_perturbations(perturbation_list, nets)
 
    sd = get_storage(file_name, info)
    
    d={}
    from_disks=[1]*12
    for net, mode in zip(nets.values(), from_disks):
        if mode==0:
            dd = run(net)    
            save(sd, dd)
            print sd
        elif mode==1:
            filt=[net.get_name()]+models+['spike_signal']
            
            dd=load(sd, *filt)
            
            dd=compute(dd, models,  ['firing_rate'], 
                        **{'firing_rate':{'time_bin':1}} )  
            dd=cmp_mean_rates_intervals(dd, intervals, amplitudes, rep)
            pp(dd)
            save(sd, dd)
        elif mode==2:
            filt=[net.get_name()]+models+['firing_rate',
                                          'mean_rates_intervals',
                                         ]
            dd=load(sd, *filt)
        d=misc.dict_update(d, dd)
        
    sd_figs=Storage_dic.load(file_name_figs)
#     if numpy.all(numpy.array(from_disks)==2):                     
    figs=[]                      
    labels=['All', 
            'Only MSN-MSN',
            'Only FSN-MSN',
            'Only FSN-MSN-static',
            'Only GPe TA-MSN',
            'No inhibition']
    
    figs.append(show_fr(d, models, **{'labels':labels}))
    figs.append(show_mr(d, models, **{'labels':labels}))
    
    sd_figs.save_figs(figs)
        
#     show_hr(d, models)

    if DISPLAY: pylab.show() 
    
    

if __name__ == "__main__":
    # stuff only to run when not called via 'import' here
    main()