sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'zzhdappdmpconf/test/integration/FirstJourney',
		'zzhdappdmpconf/test/integration/pages/DataTypeList',
		'zzhdappdmpconf/test/integration/pages/DataTypeObjectPage',
		'zzhdappdmpconf/test/integration/pages/SourceSystemObjectPage'
    ],
    function(JourneyRunner, opaJourney, DataTypeList, DataTypeObjectPage, SourceSystemObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('zzhdappdmpconf') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheDataTypeList: DataTypeList,
					onTheDataTypeObjectPage: DataTypeObjectPage,
					onTheSourceSystemObjectPage: SourceSystemObjectPage
                }
            },
            opaJourney.run
        );
    }
);