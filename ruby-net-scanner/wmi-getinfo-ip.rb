require 'win32ole'

class WIN32OLE
  def list_ole_methods
    method_names = ole_methods.collect {|m| m.name}
    # puts method_names.sort.uniq
    return method_names.sort.uniq
  end
end

HKLM                = 0x80000002
HKEY_CLASSES_ROOT   = 0x80000000
HKEY_CURRENT_USER   = 0x80000001
HKEY_LOCAL_MACHINE  = 0x80000002
HKEY_USERS          = 0x80000003
HKEY_CURRENT_CONFIG = 0x80000005
HKEY_DYN_DATA       = 0x80000006


computer = "192.168.0.175" #"127.0.0.1"
reg = WIN32OLE.connect("winmgmts://#{computer}/root/default:StdRegProv")


in_param1 = reg.Methods_("EnumKey").InParameters.SpawnInstance_()

puts "Help: " + in_param1.ole_obj_help.name.to_s
puts "Properties: " + in_param1.Properties_.to_s
puts
puts in_param1.list_ole_methods
puts

in_param1.hDefKey=HKLM
in_param1.sSubKeyName = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"
out_param1 = reg.ExecMethod_("EnumKey",in_param1)
out_param1.sNames.each { |key_names| puts key_names }

puts

in_param2 = reg.Methods_("EnumValues").InParameters.SpawnInstance_()
in_param2.hDefKey=HKLM
in_param2.sSubKeyName = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"
out_param2 = reg.ExecMethod_("EnumValues",in_param2)
out_param2.sNames.each { |value_names| puts value_names }

puts

in_param3 = reg.Methods_("GetStringValue").InParameters.SpawnInstance_()
in_param3.hDefKey=HKLM
in_param3.sSubKeyName = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"
in_param3.sValueName = "PathName"
out_param3 = reg.ExecMethod_("GetStringValue",in_param3)
puts "Value: " + out_param3.sValue.to_s
