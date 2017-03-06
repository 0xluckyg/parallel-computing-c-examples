import os

timeFile = open("time.txt", "r")

trialCount = 0;
summaryData = {};
headerString = "";

def makeKey(header):
    headerArr = header.split(" ")
    returnStr = ""
    for i in range(0, 4):
        returnStr += headerArr[i]
    return returnStr

def addToDict(time, header):
    if (summaryData.get(makeKey(header))):
        summaryData[makeKey(header)] = summaryData[makeKey(header)]+time/5
    else:
        summaryData[makeKey(header)] = time/5

def getTime(line):
    timeString = line.split("m")[1]
    timeString = timeString.replace("s", "")
    return float(timeString)

def readSummary():
    for line in timeFile:
        if "ROWS" in line:
            headerString = line
        if "real" in line:
            ++trialCount
            time = getTime(line)
            addToDict(time, headerString)

def writeSummary():
    summaryFile = open("summary.txt", "w")
    for key, value in summaryData.items():
            valueString = str(round(value, 5))
            summaryFile.write(key + ":    " + valueString + "\n")

readSummary()
writeSummary()
