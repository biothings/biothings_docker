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
  I.wait(1) // transition
  I.dontSee("default") // our conf isn't there yet
  I.click("New configuration")
  I.wait(1) // transition
  I.see("Create/edit build configuration") // see the form
  I.fillField("#conf_name","default")
  I.fillField("#doc_type","gene")
  I.selectOption("#selected_sources","cpdb")
  I.selectOption("#selected_sources","pharmgkb")
  I.selectOption("#builders","hub.databuild.builder.MyGeneDataBuilder")
  I.click("#newbuildconf_ok")
  I.wait(1) // transition
  I.dontSee("Create/edit build configuration") // form has closed
  I.click("Menu")
  I.see("default") // our conf isn't there yet
});

Scenario("Create build", (I) => {
  I.amOnPage("/")
  I.wait(1);
  I.click("Builds")
  I.click("Menu")
  I.wait(1) // transition
  I.see("default") // our conf isn't there yet
  I.click("#config_default")
  I.wait(1) // transition
  I.see("Create new build")
  I.click("#create_default")
  I.wait(1) // transition
  I.see("Enter a name for the merged data")
  I.fillField("#target_name","test_build")
  I.click("#newbuild_ok")
  I.wait(1) // transition
  I.dontSee("Enter a name for the merged data") // closed form
  I.wait(1) // transition
  I.see("test_build")
  I.wait(10) // building
  I.click("Logs")
  I.see("metadata") // up to the end
  I.click("test_build")
  I.see("total_genes")
  I.see("total_entrez_genes")
  I.see("total_ensembl_genes")
  I.see("total_ensembl_genes_mapped_to_entrez")
  I.see("total_ensembl_only_genes")
  I.see("total_species")
});

Scenario("Create full data release", (I) => {
  I.amOnPage("/")
  I.wait(1);
  I.click("Builds")
  I.wait(1)
  I.see("test_build")
  I.click("test_build")
  I.waitForText("Releases")
  I.click("Releases")
  I.see("New release")
  I.click("New release")
  I.wait(1) // transition
  I.selectOption({"name":"release_type"},"full")
  I.fillField({"name":"index_name"},"test_index")
  I.see("Select an indexer environment to create the index on")
  I.selectOption({"name":"index_env"}, "test (localhost:9200)")
  I.click("#newrelease_ok")
  I.wait(1)
  I.dontSee("Select an indexer environment to create the index on")
  I.wait(5) // indexing
  I.see("Index test_index was created on test environment")
});
