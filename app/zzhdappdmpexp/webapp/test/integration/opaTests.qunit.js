sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'zzhdappdmpexp/test/integration/FirstJourney',
		'zzhdappdmpexp/test/integration/pages/VersionList',
		'zzhdappdmpexp/test/integration/pages/VersionObjectPage',
		'zzhdappdmpexp/test/integration/pages/VersionDataObjectPage'
    ],
    function(JourneyRunner, opaJourney, VersionList, VersionObjectPage, VersionDataObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('zzhdappdmpexp') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheVersionList: VersionList,
					onTheVersionObjectPage: VersionObjectPage,
					onTheVersionDataObjectPage: VersionDataObjectPage
                }
            },
            opaJourney.run
        );
    }
);