# -*- coding: utf-8 -*-
"""
Created on Mon Oct 15 13:58:48 2018

@author: Michael
"""

import sys
#from PyQt5 import QtCore, QtGui, QtWidgets, uic
#from PyQt5.QtWidgets import QDialog, QApplication
#from PyQt5.QtCore import pyqtSlot
from PyQt5.QtWidgets import QApplication, QMainWindow, QFileDialog
from PyQt5.uic import loadUi
import scipy.io as sio
import numpy as np

from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.pyplot as plt


class dataViewer(QMainWindow):
    def __init__(self):
        super().__init__()
        loadUi('fusiViewerLayout.ui', self)
        self.setWindowTitle('This is a fUSi Data Viewer')
#        print(self.actions)
        self.actionOpen.triggered.connect(self.openFile)
        fig = Figure()
        self.myFC = FigureCanvas(fig)
        self.myFC.setParent(self)
        self.myFC.setGeometry(50, 50, 400, 250)
        self.myFC.show()
        
    def openFile(self):
        print('Clicked on Open...')
#        fileName, _ =QFileDialog.getOpenFileName(self, 'Open mat file', r'\\zubjects.cortexlab.net\Subjects\CR01\2018-03-19\1719')
        fileName, _ =QFileDialog.getOpenFileName(self, 'Open mat file', r'C:\Users\Michael\Desktop\yStacks')
        print('Will load  ' + fileName)
        data = sio.loadmat(fileName)
#        who = sio.whosmat(fileName)
#        print(who)
        params = data['params']
        Doppler = data['Doppler']
        xAxis = Doppler['xAxis'][0][0]
        zAxis = Doppler['zAxis'][0][0]
        yStack = Doppler['yStack'][0][0]
        yCoords = data['yCoords']
        
        nZ, nX, nF, nY = np.shape(yStack)
        nRows = np.floor(np.sqrt(nY))
        nColumns = np.ceil(nY/nRows)
 
        ax = self.myFC.figure.add_subplot(1, 1, 1)
        
        for iY in range(0, nY):
            ax.imshow(np.mean(np.log(yStack[:,:,:,iY]), axis = 2), aspect = 'auto')
            self.myFC.draw()
            self.myFC.show()
'''       
        fig = plt.figure()
        for iY in range(0, nY):
#            print("y = %3.1f [mm]" % yCoords[0][iY])
            ax = plt.subplot(nRows, nColumns, iY+1)
            plt.imshow(np.mean(np.log(yStack[:,:,:,iY]), axis = 2))
            ax.set_title("%3.1f [mm]" % yCoords[0][iY])
        plt.show()
'''    
            
app = QApplication(sys.argv)
widget = dataViewer()
widget.show()
#sys.exit(app.exec_())
quit(app.exec_())


