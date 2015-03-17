'''
Created on Aug 12, 2013

@author: lindahlm
'''


from toolbox.network.default_params import Perturbation_list as pl
import numpy
import pprint
from core.toolbox import misc
pp=pprint.pprint

from oscillation_perturbations8 import get_solution_slow_GP_striatum_2, update


def get():
    
    
    l=[]
    solution, s_mul, s_equal=get_solution_slow_GP_striatum_2()
    
    d0=0.8
    f_beta_rm=lambda f: (1-f)/(d0+f*(1-d0))
    
    
    x=2.5
    d={}
    for keys in s_mul: update(solution, d, keys)  
    l+=[pl(d, '*', **{'name':''})]
      
    d={}
    for keys in s_equal: update(solution, d, keys) 
    d['node']['EA']['rate']*=0.7
    
    l[-1]+=pl(d, '=', **{'name':''})    
            
    
    return l

get()