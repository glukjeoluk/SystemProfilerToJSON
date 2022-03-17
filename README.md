# SystemProfilerToJSON
~~~
let SPDataTypes:[String] =
	[
		"SPParallelATADataType",
		"SPUniversalAccessDataType",
		"SPApplicationsDataType",
		"SPAudioDataType",
		"SPBluetoothDataType",
		"SPCameraDataType",
		"SPCardReaderDataType",
		"SPComponentDataType",
		"SPDeveloperToolsDataType",
		"SPDiagnosticsDataType",
		"SPDisabledSoftwareDataType",
		"SPDiscBurningDataType",
		"SPEthernetDataType",
		"SPExtensionsDataType",
		"SPFibreChannelDataType",
		"SPFireWireDataType",
		"SPFirewallDataType",
		"SPFontsDataType",
		"SPFrameworksDataType",
		"SPDisplaysDataType",
		"SPHardwareDataType",
		"SPHardwareRAIDDataType",
		"SPInstallHistoryDataType",
		"SPNetworkLocationDataType",
		"SPLogsDataType",
		"SPManagedClientDataType",
		"SPMemoryDataType",
		"SPNVMeDataType",
		"SPNetworkDataType",
		"SPPCIDataType",
		"SPParallelSCSIDataType",
		"SPPowerDataType",
		"SPPrefPaneDataType",
		"SPPrintersSoftwareDataType",
		"SPPrintersDataType",
		"SPConfigurationProfileDataType",
		"SPSASDataType",
		"SPSerialATADataType",
		"SPSPIDataType",
		"SPSoftwareDataType",
		"SPStartupItemDataType",
		"SPStorageDataType",
		"SPSyncServicesDataType",
		"SPThunderboltDataType",
		"SPUSBDataType",
		"SPNetworkVolumeDataType",
		"SPWWANDataType",
		"SPAirPortDataType"
]

SPDataTypes.forEach { SPDataType in
	print(SystemProfiler().GetJsonString(SPDataType: SPDataType))
}
~~~
