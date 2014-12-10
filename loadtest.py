#!/usr/bin/python

#Victor Hawley / Robert Lis
#Tunesheap Load Test
#17 November 2014

from work_queue import *

import sys
import os
import time
import numpy 

port = 9523

if len(sys.argv) <= 2:
	print 'Usage: ./loadtest [# requests] [# workers]'
	sys.exit(2)
else:
	try:
		NUMREQUESTS = int(sys.argv[1])
		NUMWORKERS = int(sys.argv[2])
		
		if (NUMREQUESTS < 1 or NUMWORKERS < 1):
			sys.exit(2)
	except:
		 print "# requests and # workers must be positive integers"
		 sys.exit(2)
		 
	try:
		queue = WorkQueue(port)
	except:
		print "Instantiation of Work Queue failed!"
		sys.exit(1)
	queue.specify_name( "tunesheap" )
	for i in range(0, NUMREQUESTS): # One workqueue task for each request
		command = "curl -sL -w \"%{http_code} %{time_total} \\n\" \"https://d25xp0wafltcmt.cloudfront.net/3-song.mp3\" -o /dev/null"
		#command = "curl -sL -w \"%{http_code} %{time_total} \\n\" \"http://192.241.177.249/3-song.mp3\" -o /dev/null"
		#command = "curl -sL -w \"%{http_code} %{time_total} \\n\" \"http://www.tunesheap.com/api/v1/artists/14\" -o /dev/null"
		#command = "curl -sL -w \"%{http_code} %{time_total} \\n\" \"http://192.241.177.249:3000/api/v1/artists" -o /dev/null"
		# os.system(command)
		# Create work queue task to perform request
		wqtask = Task(command)
		# wqtask.specify_file(outfile, outfile, WORK_QUEUE_OUTPUT, cache = False)
		taskid = queue.submit(wqtask)
		# print "submitted task (id# %d)" % (taskid)

	host = os.popen('echo `hostname`.`dnsdomainname`').read().strip()
	print host + ":" + str(port)
	os.system("condor_submit_workers %s %d %d" % (host, port, NUMWORKERS))
	
	taskscompleted = 0
	totaltime = 0
	badreq = 0
	print "workers submitted to condor. waiting for tasks to complete..."
	
	responsetimes=[]

	while not queue.empty():
		task = queue.wait(5)
		if task:
			taskscompleted = taskscompleted + 1
			os.system( "clear" )
			responsecode = int(task.output.split(' ')[0])
			if (responsecode != 200):
				badreq = badreq + 1
			else:		
				seconds = task.output.split(' ')[1]
				totaltime = totaltime + float(seconds)
				print responsecode
				print seconds
				responsetimes.append(float(seconds))
				print totaltime
			# print "task (id# %d) complete: %s (return code %d)" % (task.id, task.command, task.return_status)
			print "Requests finished (regardless of status): " + str(taskscompleted) + " / " + str(NUMREQUESTS)
	os.system( "clear" )
	avgtime = totaltime / (NUMREQUESTS - badreq)
	user = os.environ['USER']
	os.system("condor_rm " + user)
	print "all tasks complete. condor workers removed. total time: " + str(totaltime) + " seconds. successful requests = " + str(NUMREQUESTS - badreq) + "/" + str(NUMREQUESTS) + ": " + str( ( float(NUMREQUESTS - badreq) / float(NUMREQUESTS)) * 100) + "%. average time per successful request: " + str(avgtime) + " seconds. stdev: " + str(numpy.std(responsetimes))
