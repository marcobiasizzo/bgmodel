# Create by Mikael Lindahl on 4/12/17.

from core.network.parameters.eneuro import EneuroPar
import pprint
import pickle
import os


def main(path, par = EneuroPar()):

    # pp = pprint.pprint

    dic = par.dic

    keys =list(dic.keys())

    for key in keys:
        if key=='node':
            for nuc in dic[key].values():
                del nuc['sets']

        pickle.dump(dic[key], open(os.path.join(path, 'parameters-'+key+'.pkl'), 'w'))

    # pp(dic)

if __name__ == '__main__':

    # mode = 'activation-control'
    mode = 'activation-dopamine-depleted'
    size = 20000

    path = os.path.join(os.getenv('BGMODEL_HOME'), 'results/example/eneuro')

    if not os.path.exists(path):
        print 'Missing '+path+'. Need to run simulate.py'
        exit(0)

    main(path)

#