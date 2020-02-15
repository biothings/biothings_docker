Feature('Studio4myvariant');

Scenario('Check few datasources', (I) => {
  I.amOnPage('/');
  I.wait(1);
  I.seeTextEquals("21","i.database.icon + span")
  I.see("NO") // no document yet
  I.see("DOCUMENT (YET)")
  // register
  I.click("Sources");
  I.waitForText("clinvar",2)
  I.see("dbsnp")
  I.see("dbnsfp")
  I.see("cgi")
  I.see("geno2mp")
  I.see("wellderly")
  I.see("clingen")
});

Scenario("Check snpeff data already there", (I) => {
  // uploaders need this one first
  I.amOnPage('/');
  I.wait(1);
  I.click("Sources");
  I.waitForText("clinvar",2)
  I.click("snpeff")
  I.waitForText("Dumper",2)
  I.see("0 document")
  I.see("success")
  I.click("Uploader")
  I.click("snpeff_hg19")
  I.waitForText("SnpeffHg19Uploader")
  I.see("success")
  I.click("snpeff_hg38")
  I.waitForText("SnpeffHg38Uploader")
  I.see("success")
  I.click("snpeff_hg38")
});

Scenario("Dump/upload cgi", (I) => {
  I.amOnPage('/');
  I.wait(1);
  I.click("Sources");
  I.waitForText("clingen",2)
  I.click("cgi")
  I.waitForText("Dumper",2)
  I.see("0 document")
  I.click("Dump")
  I.waitForText("success",20)
  I.click("Uploader")
  I.waitForText("success",5*60) // snpeff is long
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
  I.fillField("#doc_type","variant")
  I.selectOption("#selected_sources","cgi")
  I.selectOption("#selected_sources","snpeff_hg19")
  // TODO: can't find a way to add a root source...
  // root sources are populated dynamically from selected sources so we need to open the list
  //I.click("Root sources")
  //I.click({"css":"div[class=\"item\"][data-value=\"cgi\"]"})
  I.selectOption("#builders","hub.databuild.builder.MyVariantDataBuilder")
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
  I.waitForText("test_build",30)
  I.wait(60) // building
  I.click("Logs")
  I.see("metadata") // up to the end
  I.click("test_build")
  I.see("observed")
  I.see("hg19")
  I.see("vcf")
  I.see("total")
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
  I.waitForText("Index test_index was created on test environment",60) // indexing
});

Scenario("Create myvariant API", (I) => {
  I.amOnPage("/")
  I.wait(1);
  I.click("API")
  I.wait(1)
  I.click("Menu")
  I.wait(1) // transition
  I.see("New API")
  I.click("New API")
  I.waitForText("Enter a name for the API",2)
  I.fillField({"name":"api_id"},"my_api")
  I.fillField({"name":"port"},8000)
  I.selectOption({"name":"api_backend"},"test (localhost:9200 | test_index)")
  I.click("#newapi_ok")
  I.waitForText("ElasticSearch host")
  I.wait(5)
  I.click(".play")
  I.waitForText("running",5)
  I.see("Query:")
  I.see(":8000/query?q=*")
});

