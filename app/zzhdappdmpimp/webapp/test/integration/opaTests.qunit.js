sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'zzhdappdmpimp/test/integration/FirstJourney',
		'zzhdappdmpimp/test/integration/pages/ImportList',
		'zzhdappdmpimp/test/integration/pages/ImportObjectPage',
		'zzhdappdmpimp/test/integration/pages/ImportItemObjectPage'
    ],
    function(JourneyRunner, opaJourney, ImportList, ImportObjectPage, ImportItemObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('zzhdappdmpimp') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheImportList: ImportList,
					onTheImportObjectPage: ImportObjectPage,
					onTheImportItemObjectPage: ImportItemObjectPage
                }
            },
            opaJourney.run
        );
    }
);