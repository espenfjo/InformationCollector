InformationCollector
====================

A script that will collect some amount of information about a Linux system


Its intention is to be run as a forensic tool to help doing investigational tasks for operational technicians.

It currently collects the following information:
* Running processes with some information
* Open files
* Network connections and information
* Logs up to two days old

It can for example be invoked as such `curl https://raw.github.com/espenfjo/InformationCollector/master/InformationCollector.sh | bash`.

It will output an `InformationCollecto-$(date +%y%m%d).tgz` file containing the most relevant information.