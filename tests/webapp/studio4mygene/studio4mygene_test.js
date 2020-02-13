Feature('Studio4mygene');

Scenario('Check few datasources', (I) => {
  I.amOnPage('/');
  I.wait(1);
  I.seeTextEquals("27","i.database.icon + span")
  I.see("NO") // no document yet
  I.see("DOCUMENT (YET)")
  // register
  I.click("Sources");
  I.waitForText("clingen",2)
  I.see("cpdb")
  I.see("reporter")
  I.see("wikipedia")
  I.see("ensembl")
  I.see("entrez")
  I.see("entrez_unigene")
});

Scenario("Dump/upload cpdb", (I) => {
  I.amOnPage('/');
  I.wait(1);
  I.click("Sources");
  I.waitForText("clingen",2)
  I.click("cpdb")
  I.waitForText("Dumper",2)
  I.see("0 document")
  I.click("Dump")
  I.waitForText("success",20)
  I.click("Uploader")
  I.waitForText("success",30)
  I.dontSee("0 document")
  I.click("Sources");
  I.waitForText("clingen",2)
});

Scenario("Dump/upload pharmgkb", (I) => {
  I.amOnPage('/');
  I.wait(1);
  I.click("Sources");
  I.waitForText("clingen",2)
  I.click("pharmgkb")
  I.waitForText("Dumper",2)
  I.see("0 document")
  I.click("Dump")
  I.waitForText("success",20)
  I.click("Uploader")
  I.waitForText("success",30)
  I.dontSee("0 document")
  I.click("Sources");
  I.waitForText("clingen",2)
});

Scenario("Create build config", (I) => {
  I.amOnPage("/")
  I.wait(1);
  I.click("Builds")
  I.click("Menu")
  I.click("New configuration")
  I.fillField("#conf_name","default")
  I.fillField("#doc_type","gene")
  I.selectOption("#selected_sources","cpdb")
  I.selectOption("#selected_sources","pharmgkb")
  I.selectOption("#builders","hub.databuild.builder.MyGeneDataBuilder")
  //I.click("OK") // cén't find, more than one
});

