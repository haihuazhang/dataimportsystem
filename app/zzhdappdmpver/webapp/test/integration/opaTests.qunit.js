sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'zzhdappdmpver/test/integration/FirstJourney',
		'zzhdappdmpver/test/integration/pages/VersionList',
		'zzhdappdmpver/test/integration/pages/VersionObjectPage',
		'zzhdappdmpver/test/integration/pages/VersionDataObjectPage'
    ],
    function(JourneyRunner, opaJourney, VersionList, VersionObjectPage, VersionDataObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('zzhdappdmpver') + '/index.html'
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