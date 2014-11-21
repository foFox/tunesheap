#!/usr/bin/python

#Victor Hawley / Robert Lis
#Tunesheap Load Test
#17 November 2014

from work_queue import *

import sys
import os

port = 9431

if len(sys.argv) <= 2:
	print 'Usage: ./loadtest [# requests] [# workers]'
	sys.exit(2)
else:
	try:
		NUMREQUESTS = int(sys.argv[1])
		NUMWORKERS = int(sys.argv[2])
	except:
		 print "# requests and # workers must be integers"
		 sys.exit(2)
		 
	try:
		queue = WorkQueue(port)
	except:
		print "Instantiation of Work Queue failed!"
		sys.exit(1)
	queue.specify_name( "tunesheap" )
	for i in range(0, NUMREQUESTS): # One workqueue task for each request
		outfile = "request_" + str(i) + ".out"	
		command = "curl http://www.tunesheap.com > " + outfile
		# os.system(command)
		# Create work queue task to perform request
		wqtask = Task(command)
		wqtask.specify_file(outfile, outfile, WORK_QUEUE_OUTPUT, cache = False)
		taskid = queue.submit(wqtask)
		# print "submitted task (id# %d)" % (taskid)

	host = os.popen('echo `hostname`.`dnsdomainname`').read().strip()
	print host + ":" + str(port)
	os.system("condor_submit_workers %s %d %d" % (host, port, NUMWORKERS))
	
	taskscompleted = 0
	print "workers submitted to condor. waiting for tasks to complete..."
	while not queue.empty():
		task = queue.wait(5)
		if task:
			taskscompleted = taskscompleted + 1
			os.system( "clear" )
			print "task (id# %d) complete: %s (return code %d)" % (task.id, task.command, task.return_status)
			print "Requests finished (regardless of status): " + str(taskscompleted) + " / " + str(NUMREQUESTS)
	os.system( "clear" )
	
	user = os.environ['USER']
	os.system("condor_rm " + user)

	print "all tasks complete. condor workers removed."