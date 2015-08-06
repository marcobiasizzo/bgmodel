'''
Created on Aug 12, 2013

@author: lindahlm
'''
from core import monkey_patch as mp
mp.patch_for_milner()

from scripts_inhibition import config
from scripts_inhibition.base_simulate import (
                      pert_add_go_nogo_ss, 
                      get_args_list_Go_NoGo_compete_oscillation,
                      get_kwargs_list_indv_nets,
                      get_path_rate_runs)

from core.network.manager import Builder_Go_NoGo_with_lesion_FS_base_oscillation as Builder
from core.parallel_excecution import loop
from core import directories as dr
from core import my_socket
from core.network.default_params import Perturbation_list as pl

import scripts_inhibition.base_Go_NoGo_compete as module
import test_fig_06_pert as op

import sys
import pprint
pp=pprint.pprint

path_rate_runs=get_path_rate_runs('test_fig_06_sim_inh/')
ops=[op.get()[0]] #0 is beta


FILE_NAME=__file__.split('/')[-1][0:-3]
FROM_DISK_0=int(sys.argv[1]) if len(sys.argv)>1 else 0
LOAD_MILNER_ON_SUPERMICRO=False
NUM_NETS=5
NUM_RUNS=len(ops) 
num_sims=NUM_NETS*NUM_RUNS

dc=my_socket.determine_computer
CORES=40*4 if dc()=='milner' else 2
JOB_ADMIN=config.Ja_milner if dc()=='milner' else config.Ja_else
LOCAL_NUM_THREADS= 40 if dc()=='milner' else 2
WRAPPER_PROCESS=config.Wp_milner if dc()=='milner' else config.Wp_else

amp_base=1.1
freq= 0.0
STN_amp_mod=3.
kwargs={
        
        'amp_base':amp_base,

        'Builder':Builder,
        
        'cores':CORES,
        
        'debug':False,
        'do_not_record':[], 
        'do_runs':range(NUM_RUNS),
        'do_obj':False,

        'file_name':FILE_NAME,
        'freqs':[freq], #need to be length  1
        'freq_oscillations':20.,
        'from_disk_0':FROM_DISK_0,
        
        'i0':FROM_DISK_0,
        'input_type':'burst3_oscillations',
        
        'job_admin':JOB_ADMIN, #user defined clas
        'job_name':'fig6_0.2rest',

        'l_hours':['02','01','00'],
        'l_mean_rate_slices':['mean_rate_slices'],
        'l_minutes':['00','00','05'],
        'l_seconds':['00','00','00'],            
        'labels':['Only D1', 
                   'D1,D2',
                   'MSN lesioned (D1, D2)',
                   'FSN lesioned (D1, D2)',
                   'GPe TA lesioned (D1,D2)'], 
        
        'local_num_threads':LOCAL_NUM_THREADS,
                 
        'max_size':20000.,
        'module':module,
        
        'nets':['Net_0', 'Net_1', 'Net_2', 'Net_3', 'Net_4'],
        'nets_to_run':['Net_0', 'Net_1', 'Net_2', 'Net_3', 'Net_4'],
        
        'other_scenario':True,
                 
        'path_rate_runs':path_rate_runs,
        'path_results':dr.HOME_DATA+ '/'+ FILE_NAME + '/',       
        'perturbation_list':ops,
        
        'proportion_connected':[0.2]*NUM_RUNS,#NUM_NETS, #related to toal number fo runs
        'p_sizes':[1.],
        'p_subsamp':[1.],
        
        'STN_amp_mod':STN_amp_mod,
 
        'tuning_freq_amp_to':'M2',
        
        'wrapper_process':WRAPPER_PROCESS, #user defined wrapper of subprocesses
         
        }

if my_socket.determine_computer()=='milner':
    kw_add={
            'duration':[907., 100.0],
            'laptime':1007.,
            'res':10, 
            'rep':5,
            'time_bin':100.,

            }
elif my_socket.determine_computer() in ['thalamus','supermicro']:
    kw_add={
            'duration':[357., 100.0],
            'laptime':457.,
            'res':3, 
            'rep':5,
            'time_bin':1000./256,
            }

kwargs.update(kw_add)

p_list=pert_add_go_nogo_ss(**kwargs)

for i, p in enumerate(p_list): print i, p

a_list=get_args_list_Go_NoGo_compete_oscillation(p_list, **kwargs)
k_list=get_kwargs_list_indv_nets(len(p_list), kwargs)

loop(num_sims, [num_sims,num_sims,NUM_RUNS], a_list, k_list )
        