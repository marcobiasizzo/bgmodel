'''
Created on Aug 12, 2013

@author: lindahlm
'''


from toolbox.network.default_params import Perturbation_list as pl
import numpy
import pprint
from core.toolbox import misc
pp=pprint.pprint

from oscillation_perturbations8 import get_solution_slow_GP_striatum, update


def get():
    
    
    l=[]
    solution, s_mul, s_equal=get_solution_slow_GP_striatum()
    
    d0=0.8
    f_beta_rm=lambda f: (1-f)/(d0+f*(1-d0))
    
    
    for y in numpy.arange(0.9,0.0,-0.2):
        x=2.5
        d={}
        for keys in s_mul: update(solution, d, keys)  

        misc.dict_update(d,{'conn':{'nest':{'GI_GA_gaba':{'weight':y}}}})
        l+=[pl(d, '*', **{'name':''})]
    

          
        d={}
        for keys in s_equal: update(solution, d, keys) 
        
        misc.dict_update(d,{'nest':{'ST':{'beta_I_AMPA_1': f_beta_rm(x)}}})
        misc.dict_update(d,{'nest':{'ST':{'beta_I_NMDA_1': f_beta_rm(x)}}})
        d['node']['EA']['rate']*=0.7
        
    
        l[-1]+=pl(d, '=', **{'name':'mod_ST_beta_'+str(x)})    
            
    
    return l

get()