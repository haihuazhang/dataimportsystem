sap.ui.define(["sap/m/MessageToast", 
	// "zzhdappdmpexp/ext/list/JSONViewer",
	"zzhdappdmpexp/control/json/json-viewer"
], function (MessageToast, JsonViewer1) {
	"use strict";
	return {
		previewButtonPressed: function (oEvent) {
			// MessageToast.show("Button pressed for item " + oEvent.getSource().getBindingContext().getObject().ID);
			if (oEvent.getSource().getBindingContext()) {
				var sJson = oEvent.getSource().getBindingContext().getProperty("DataJson");
				var oJSON = JSON.parse(sJson);
				// const jsonViewer = document.createElement("andypf-json-viewer")
				// jsonViewer.id = "json"
				// jsonViewer.expanded = 2
				// jsonViewer.indent = 2
				// jsonViewer.showDataTypes = true
				// jsonViewer.theme = "monokai"
				// jsonViewer.showToolbar = true
				// jsonViewer.showSize = true
				// jsonViewer.showCopy = true
				// jsonViewer.expandIconType = "square"
				// jsonViewer.data = oJSON;
				// var viewers = {
				// 	default: new JSONViewer({
				// 		eventHandler: document.body,
				// 		indentSize: 20,
				// 		expand: 1,
				// 		quoteKeys: true
				// 	}),
				// 	dark: new JSONViewer({
				// 		eventHandler: document.body,
				// 		indentSize: 20,
				// 		expand: 1,
				// 		quoteKeys: false,
				// 		theme: 'dark'
				// 	})
				// };


				this.pDialog ??= this.loadFragment({
					name: "zzhdappdmpexp.ext.list.JSONViewDialog"
				});
				this.pDialog.then((oDialog) => {
					
					sap.ui.getCore().byId("jsonViewer").setContent(
						// viewers.default.toJSON(oJSON)
						jsonViewer(oJSON, false)
					);
					oDialog.open();
				});

				this.onJSONViewDialogClose = function (oEvent) {
					this.pDialog.then((oDialog) => oDialog.close());
				}





			}
		},
		// onSelectionChange: function (oEvent) {
		// MessageToast.show(
		// 	"Segmented button item '" +
		// 		oEvent.getParameter("item").getText() +
		// 		"' selected for item " +
		// 		oEvent.getSource().getBindingContext().getObject().ID
		// );
		// }
	};
});
