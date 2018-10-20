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

class dataViewer(QMainWindow):
    def __init__(self):
        super().__init__()
        loadUi('fusiViewerLayout.ui', self)
        self.setWindowTitle('This is a fUSi Data Viewer')
#        print(self.actions)
        self.actionOpen.triggered.connect(self.openFile)
        
    def openFile(self):
        print('Clicked on Open...')
        fileName, _ =QFileDialog.getOpenFileName(self, 'Open mat file', r'\\zubjects.cortexlab.net\Subjects\CR01\2018-03-19\1719')
        print('Will load  ' + fileName)
        data = sio.loadmat(fileName)
#        who = sio.whosmat(fileName)
#        print(who)
        params = data['params']
        doppler = data['Doppler']
        dir(data)
            
app = QApplication(sys.argv)
widget = dataViewer()
widget.show()
#sys.exit(app.exec_())
quit(app.exec_())


