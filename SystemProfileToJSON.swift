import Foundation
import SwiftyJSON

public struct SystemProfiler
{
	fileprivate class SystemProfilerData
	{
		var depth: Int
		var data: Dictionary<String, String>
		
		var parent: Optional<SystemProfilerData>
		var prev: Optional<SystemProfilerData>
		var next: Optional<SystemProfilerData>
		
		var childs: Array<Optional<SystemProfilerData>>
		
		init()
		{
			depth = 0
			data = Dictionary<String, String>()
			
			parent = nil
			prev = nil
			next = nil
			
			childs = Array<Optional<SystemProfilerData>>()
		}
	}
	
	fileprivate func ReadSPDataType(SPDataType: String) -> [String]
	{
		let pipe = Pipe()
		let task = Process()
		
		task.launchPath = "/usr/sbin/system_profiler"
		task.arguments = [SPDataType]
		task.standardOutput = pipe
		
		task.launch()
		
		var readData: String = ""
		while(true)
		{
			guard case let availableData = pipe.fileHandleForReading.availableData, 0 < availableData.count else
			{
				break
			}
			
			if let rd = String(data:availableData, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue))
			{
				readData += rd
			}
		}
		
		task.waitUntilExit()
		
		return readData.split(separator: Character("\n")).map{ String($0) }
	}
	
	fileprivate func SplitKeyValue(dataTypes: [String], separateBy: String) -> Array<SystemProfilerData>
	{
		var key_value: Array<SystemProfilerData> = Array<SystemProfilerData>()
		
		for dataType in dataTypes
		{
			let device_info_data: SystemProfilerData = SystemProfilerData()
			var depth: Int = 0
			for i in 0..<dataType.count
			{
				if " " != Array(dataType)[i]
				{
					break
				}
				
				depth = depth + 1
			}
			
			device_info_data.depth = depth;
			
			var split_data = dataType.trimmingCharacters(in: .whitespaces).components(separatedBy: separateBy)
			
			let key: String = split_data[0].trimmingCharacters(in: .whitespaces)
			var value: String = String()
			
			for i in 1..<split_data.count
			{
				value = value + split_data[i]
				if(i < (split_data.count-1))
				{
					value = value + separateBy
				}
			}
			value = value.trimmingCharacters(in: .whitespaces)
			
			device_info_data.data[key] = value
			
			key_value.append(device_info_data)
		}
		
		return key_value
	}
	
	fileprivate func SetNodeInfo(datas: inout Array<SystemProfilerData>)
	{
		for i in 0..<datas.count
		{
			let next_index = i + 1
			if(next_index == datas.count)
			{
				break
			}
			
			if(datas[i].depth < datas[next_index].depth)
			{
				datas[next_index].parent = datas[i]
				datas[i].childs.append(datas[next_index])
				
				// find sibling node
				var next_sibling_index = next_index
				for sibling_index in (next_index + 1)..<datas.count
				{
					if(nil != datas[sibling_index].parent) // another parent node
					{
						break
					}
					
					if(datas[next_index].depth == datas[sibling_index].depth)
					{
						datas[sibling_index].parent = datas[i]
						datas[i].childs.append(datas[sibling_index])
						
						datas[next_sibling_index].next = datas[sibling_index]
						datas[sibling_index].prev = datas[next_sibling_index]
						next_sibling_index = sibling_index
					}
				}
			}
		}
	}
	
	fileprivate func CreateJSon(data: SystemProfilerData) -> JSON
	{
		var jChild: JSON = JSON()
		
		if(0 < data.childs.count)
		{
			for child in data.childs
			{
				guard let _child = child else { continue }
				guard let _first = _child.data.first else { continue }
				
				if(_first.value.count < 0)
				{
					continue
				}
				
				if(0 < _child.childs.count)
				{
					let value = jChild[_first.key]
					switch value.type
					{
					case .null:
						jChild[_first.key] = JSON(CreateJSon(data: _child))
						
					case .array: // alread exist
						var jValue:Array<JSON> = Array<JSON>()
						value.arrayValue.forEach{ v in jValue.append(v) }
						jValue.append(CreateJSon(data: _child))
						jChild[_first.key] = JSON(jValue)
						
					default: // alread exist
						let jValue = [value, CreateJSon(data: _child)]
						jChild[_first.key] = JSON(jValue)
					}
				}
				else
				{
					let value = jChild[_first.key]
					switch value.type
					{
					case .null:
						jChild[_first.key] = JSON(_first.value)
						
					case .array: // alread exist
						var jValue:Array<String> = Array<String>()
						value.arrayValue.forEach{ v in jValue.append(v.stringValue) }
						jValue.append(_first.value)
						jChild[_first.key] = JSON(jValue)
						
					default: // alread exist
						let jValue = [value.stringValue, _first.value]
						jChild[_first.key] = JSON(jValue)
					}
				}
			}
		}
		
		return jChild
	}
	
	fileprivate func PrintData(data: SystemProfilerData, blank: String)
	{
		guard let _first = data.data.first else { return }
		print("\(blank)\(_first.key): \(_first.value)")
		
		data.childs.forEach { child in
			guard let _child = child else { return }
			PrintData(data: _child, blank: ((0 < _child.depth) ? blank + "\t" : ""))
		}
	}
	
	public func GetJsonObject(SPDataType: String) -> JSON
	{
		let SPData = ReadSPDataType(SPDataType: SPDataType)
		if(0 < SPData.count)
		{
			var datas = SplitKeyValue(dataTypes: SPData,
									  separateBy: ":")
			SetNodeInfo(datas: &datas)
			//PrintData(data: datas[0], blank: "")
			
			let jdata =  JSON([datas[0].data.first?.key : CreateJSon(data: datas[0])])
			
			return jdata;
		}
		
		return JSON([SPDataType:""])
	}
	
	public func GetJsonString(SPDataType: String) -> String
	{
		return GetJsonObject(SPDataType: SPDataType).rawString() ?? ""
	}
}
