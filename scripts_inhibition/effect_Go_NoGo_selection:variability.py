'''
Created on Nov 14, 2014

@author: mikael
'''
import matplotlib.gridspec as gridspec
import toolbox.plot_settings as ps
import pylab
import pprint
pp=pprint.pprint

from scripts_inhibition import effect_conns
from toolbox import misc
from simulate import save_figures
from Go_NoGo_compete import (show_heat_map, 
                             show_variability, 
                             show_variability_several, 
                             gs_builder_var,
                             gs_builder_var_mul)


def gs_builder(*args, **kwargs):

    n_rows=kwargs.get('n_rows',2)
    n_cols=kwargs.get('n_cols',3)
    order=kwargs.get('order', 'col')
    
    gs = gridspec.GridSpec(n_rows, n_cols)
    gs.update(wspace=kwargs.get('wspace', 0. ), 
              hspace=kwargs.get('hspace', 0.4 ))

    iterator = [[slice(2,7), slice(1,8)],
                [slice(2,7), slice(9,16)],
                [slice(8,13), slice(1,8)],
                [slice(8,13), slice(9,16)],
                [slice(14,19), slice(1,8)],
                [slice(14,19), slice(9,16)]]
    
    return iterator, gs, 

attrs=['mean_rate_slices', 'set_0', 'set_1']
models=['M1', 'M2', 'SN']
paths=[]



# paths.append('/home/mikael/results/papers/inhibition/network/'
#              +'milner/simulate_Go_NoGo_XXX_no_ss_act0.2_ST_pulse_v2/')

paths.append('/home/mikael/results/papers/inhibition/network/'
             +'milner/simulate_Go_NoGo_XXX_nodop_FS_recovery_cases_beta_amp_1.1/')
paths.append('/home/mikael/results/papers/inhibition/network/'
             +'milner/simulate_Go_NoGo_XXX_nodop_FS_recovery_cases_no_beta_amp_1.1/')
paths.append('/home/mikael/results/papers/inhibition/network/'
             +'milner/fig5_2_Go_NoGo_XXX_no_ss_act0.2_v2/')


# s1='script_000{0}_exc1.0_EIEACS_600.0_STGAw_0.1875_GAGA_5.0_GIGA_25.0-ss-1.0'
s1='script_000{0}_exc1.0_EIEACS_600.0_STGAw_0.1875_GAGA_5.0_GIGA_25.0-ss-1.0--Normal'
s2='script_000{0}_exc1.0_EIEACS_600.0_STGAw_0.1875_GAGA_5.0_GIGA_25.0-ss-1.0'
nets1=['Net_0', 'Net_1', 'Net_2', 'Net_3', 'Net_4']
nets2=['Net_0']
files={
       'beta':[paths[0]+s1.format(0), nets2],
       'no_beta':[paths[1]+s1.format(0), nets2],
       'normals':[paths[2]+s2.format(0), nets1],
       }


d={}
for key, val in files.items():
    nets=val[1]
    d_tmp=effect_conns.gather('', nets, models, attrs, 
                              dic_keys=[key], 
                              file_names=[val[0]])
    misc.dict_update(d, d_tmp)

print d.keys()
# pp(d)


builder=[['beta', nets2],
         ['no_beta', nets2],
         ['normals', nets1]]
dd={}
i=0
for name, nets in builder:
    for net in nets:
        print name, net
        if not (net in d[name].keys()):
            i+=1
            continue
        dd['Net_{:0>2}'.format(i)]=d[name][net]
        
#         titles.append(name+'_'+net)
        i+=1 
# for name, nets in builder:
#     for net in nets:
#         dd['Net_{}'.format(i)]=d[name][net]
#         i+=1 
pp(dd)
print len(dd['Net_00']['set_1']['SN']['mean_rate_slices'].y)

# scale=8
# fig, axs=ps.get_figure2(n_rows=10, 
#                         n_cols=26,
#                         w=int(72/2.54*20*(17./48))*scale,
#                         h=100*scale,  
#                         fontsize=7*scale,
#                         title_fontsize=7*scale,
#                         gs_builder=gs_builder_var) 
# 
# k={'axs':axs,
#    'do_colorbar':False, 
#    'fig':fig,
#    'models':['SN'],
#    'print_statistics':False,
#    'resolution':10,
#    'scale':scale,
#    'titles':['D1 & D2 beta',
#              'D1 & D2 no beta',
#              r'No MSN$\to$MSN',
#              r'No FSN$\to$MSN',
#              r'No $GPe_{TA}$$\to$MSN',
#              r'Pulse STN'],
#     'type_of_plot':'mean',
#     'vlim_rate':[-100, 100]}
# 
# 
# 
# 
# 
# # show_heat_map(dd, 'mean_rate_slices', **k)
# # show_variability(dd, 'mean_rate_slices', **k)
# # show_variability(dd, 'mean_rate_slices', net='Net_01',**k)
# show_variability(dd, 'mean_rate_slices', net='Net_03',**k)
# show_variability(dd, 'mean_rate_slices', net='Net_05',**k)
# show_variability(dd, 'mean_rate_slices', net='Net_06',**k)

scale=8
fig, axs=ps.get_figure2(n_rows=12*3, 
                        n_cols=12*2,
                        w=int(72/2.54*20*(17./48))*scale,
                        h=300*scale,  
                        fontsize=7*scale,
                        title_fontsize=7*scale,
                        grid=[3,2],
                        gs_builder=gs_builder_var_mul) 
len(axs)
pylab.show()
k={'axs':axs,
   'do_colorbar':False, 
   'fig':fig,
   'models':['SN'],
   'print_statistics':False,
   'resolution':10,
   'scale':scale,
   'titles':['D1 & D2 beta',
             'D1 & D2 no beta',
             r'No MSN$\to$MSN',
             r'No FSN$\to$MSN',
             r'No $GPe_{TA}$$\to$MSN',
             r'Pulse STN'],
    'type_of_plot':'mean',
    'vlim_rate':[-100, 100]}





pylab.show()