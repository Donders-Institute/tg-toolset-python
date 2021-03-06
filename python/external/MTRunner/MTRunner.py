#!/usr/bin/env python
import time
import traceback
from threading import Lock
from Queue import Empty
from Algorithm import AlgorithmError
from GangaThread import GangaThread
from Data import DuplicateDataItemError 
from Common import getMyLogger

class MTRunnerError(Exception):
    """
    Class for general MTRunner errors.
    """

    def __init__(self, message):
        self.message = message

class GangaWorkAgent(GangaThread):

    def __init__(self, runnerObj, name):
        GangaThread.__init__(self, name=name)
        self._runner = runnerObj
        self.setLogLevel(0)

    def setLogLevel(self, lvl):
        self.logger  = getMyLogger('MTRunner_%s' % self.name, lvl)

    def run(self):

        while not self.should_stop():

            if self._runner.data.isEmpty():

                if self._runner.keepAlive:
                    #if self.debug:
                    #    print 'data queue is empty, check again in 0.5 sec.'
                    time.sleep(0.5)
                    continue
                else:
                    self.logger.debug('data queue is empty, stop worker')
                    break
            else:
                try:
                    item = self._runner.data.getNextItem()

                    ## write out the debug log
                    #self._runner.lock.acquire()
                    #f = open('/tmp/hclee/mt_debug.log','a')
                    #f.write( 'worker %s get item %s \n' % (self.getName(), item) )
                    #f.close()
                    #self._runner.lock.release()

                    self.logger.debug( 'worker %s get item %s' % (self.getName(), item) )
                    rslt = self._runner.algorithm.process(item)
                    if rslt:
                        self._runner.lock.acquire()
                        self._runner.doneList.append(item)
                        self._runner.lock.release()
                except NotImplementedError:
                    break
                except AlgorithmError:
                    break
                except Empty:
                    pass
                except:
                    traceback.print_exc()
                    pass

        self.unregister()
        

class MTRunner:
    """
    Class to handle multiple concurrent threads running on the same algorithm. 
    
    @since: 0.0.1
    @author: Hurng-Chun Lee 
    @contact: hurngchunlee@gmail.com

    The class itself is a thread. To run it; doing the following:

        runner = MTRunner(myAlgorithm, myData)
        runner.start()
        ... you can do something in parallel in your main program ...
        runner.join()

    where 'myAlorithm' and 'myData' are two objects defining your own
    algorithm running on a dataset.
    """

    _attributes = ('name', 'algorithm', 'data', 'numThread', 'doneList', 'lock', 'keepAlive')

    def __init__(self, name, algorithm=None, data=None, numThread=10, keepAlive=False):
        """
        initializes the MTRunner object. 
        
        @since: 0.0.1
        @author: Hurng-Chun Lee 
        @contact: hurngchunlee@gmail.com

        @param algorithm is an Algorithm object defining how to process on the data
        @param data is an Data object defining what to be processed by the algorithm
        """

        if (not algorithm) or (not data):
            raise MTRunnerError('algorithm and data must not be None') 

        self.algorithm = algorithm
        self.data      = data
        self.numThread = numThread
        self.doneList  = []
        self.lock      = Lock()
        self.name      = name
        self.keepAlive = keepAlive
        self._agents   = []
        self.setLogLevel(0)

    def setLogLevel(self, lvl):
        self._lvl    = lvl
        self.logger  = getMyLogger('MTRunner', lvl)
        for t in self._agents:
            t.setLogLevel(lvl)

    def getDoneList(self):
        """
        gets the data items that have been processed correctly by the algorithm.
        """
        return self.doneList

    def getResults(self):
        """
        gets the overall results (e.g. output) from the algorithm.
        """
        return self.algorithm.getResults()

    def addDataItem(self, item):
        """
        adds a new data item into the internal queue
        """
        try:
            self.data.addItem(item)
        except DuplicateDataItemError, e:
            self.logger.debug('skip adding new item: %s' % e.message)
            pass

    def start(self):
        """
        starts the MTRunner
        """

        for i in range(self.numThread):
            t = GangaWorkAgent( runnerObj=self, name='%s_worker_agent_%d' % (self.name, i) )
            t.setLogLevel(self._lvl)
            self._agents.append(t)
            t.start()

    def join(self, timeout=-1):
        """
        joins the worker agents.

        The caller will be blocked until exceeding the timeout or all worker agents finish their jobs.
        """

        ## check the number of alive threads
        try:
            t1 = time.time()

            while self.__cnt_alive_threads__() > 0:
                t2 = time.time()

                ## break the loop if exceeding the timeout
                if timeout >= 0 and t2-t1 > timeout:
                    break
                else:
                    ## sleep for another 0.5 second
                    time.sleep(0.5)

        except KeyboardInterrupt:
            self.logger.error('Keyboard interruption on MTRunner: %s' % self.name)

    def stop(self, timeout=-1):
        """
        waits worker agents to finish their works.
        """

        ## ask all agents to stop
        for agent in self._agents:
            agent.stop()

        self.join(timeout=timeout)


    def __cnt_alive_threads__(self):

        num_alive_threads = 0
        for t in self._agents:
            if t.isAlive():
                num_alive_threads += 1

        return num_alive_threads

