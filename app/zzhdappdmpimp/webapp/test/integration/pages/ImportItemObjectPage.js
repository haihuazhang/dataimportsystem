sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'zzhdappdmpimp',
            componentId: 'ImportItemObjectPage',
            contextPath: '/Import/_ImportItem'
        },
        CustomPageDefinitions
    );
});