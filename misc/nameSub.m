function dOut = nameSub(d, oldName, newName)

dOut = d;

dOut.params.animalName = strrep(d.params.animalName, oldName, newName);
dOut.params.experimentName = strrep(d.params.experimentName, oldName, newName);
dOut.params.animal = strrep(d.params.animal, oldName, newName);
dOut.params.images = strrep(d.params.images, oldName, newName);
dOut.params.info = strrep(d.params.info, oldName, newName);
dOut.params.fus = strrep(d.params.fus, oldName, newName);
dOut.params.fulldata = strrep(d.params.fulldata, oldName, newName);
dOut.params.fileJournal = strrep(d.params.fileJournal, oldName, newName);