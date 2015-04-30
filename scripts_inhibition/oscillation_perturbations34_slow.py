'''
Created on Aug 12, 2013

@author: lindahlm
'''


from toolbox.network.default_params import Perturbation_list as pl
import numpy
import pprint
from core.toolbox import misc
pp=pprint.pprint

from oscillation_perturbations8 import get_solution_slow_GP_striatum_2


def get():
    
    
    l=[]
    solution=get_solution_slow_GP_striatum_2()

    d0=0.8
    f_beta_rm=lambda f: (1-f)/(d0+f*(1-d0))
    for y in [1.2, 1.25]:
      
        d={}
        misc.dict_update(d, solution['mul'])
        
        misc.dict_update(d,{'node':{'CS':{'rate': y}}}) 
        
        l+=[pl(d, '*', **{'name':''})]
          
        d={}
        misc.dict_update(d, solution['equal']) 
    
        d['node']['EI']['rate']*=y
        d['node']['EA']['rate']*=0.0
        
        misc.dict_update(d,{'nest':{'GI':{'beta_I_GABAA_1': f_beta_rm(2)}}})
          
        l[-1]+=pl(d, '=', **{'name':'all_CSEIEA_'+str(y)})  
        

    for z in [1.1, 1.2]:
        y=1.25
        d={}
        misc.dict_update(d, solution['mul'])
        
        misc.dict_update(d,{'node':{'CS':{'rate': y}}}) 
        misc.dict_update(d,{'node':{'CF':{'rate': z}}}) 
                
        l+=[pl(d, '*', **{'name':''})]
          
        d={}
        misc.dict_update(d, solution['equal']) 
    
        d['node']['EI']['rate']*=y
        d['node']['EA']['rate']*=0.0

        
        misc.dict_update(d,{'nest':{'GI':{'beta_I_GABAA_1': f_beta_rm(2)}}})
          
        l[-1]+=pl(d, '=', **{'name':'all_CF_'+str(z)})


    for y in numpy.arange(5.,29.,5.):       
        z=1.25
        
        d={}
        misc.dict_update(d, solution['mul'])  
        misc.dict_update(d,{'node':{'CS':{'rate': z}}}) 
        l+=[pl(d, '*', **{'name':''})]
          
        d={}
        misc.dict_update(d, solution['equal']) 
        
        dd={'conn': {'GA_GA_gaba':{'fan_in0': y,'rule':'all-all' }, 
                     'GA_GI_gaba':{'fan_in0': 2,'rule':'all-all' },
                     'GI_GA_gaba':{'fan_in0': 30-y,'rule':'all-all' },
                     'GI_GI_gaba':{'fan_in0': 28,'rule':'all-all' }}}
        
        misc.dict_update(d, dd)
         
         
        d['node']['EI']['rate']*=z
        d['node']['EA']['rate']*=0.0

        misc.dict_update(d,{'nest':{'GI':{'beta_I_GABAA_1': f_beta_rm(2)}}})
   
       
        l[-1]+=pl(d, '=', **{'name':'GAGA_'+str(y)+'_GIGA_'+str(30-y)}) 
        
    return l
get()