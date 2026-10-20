import Foundation
import Testing
@testable import XKit

@Test func memoryEntitlementsMapToDeveloperCapabilities() throws {
    let plist = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>com.apple.developer.kernel.increased-memory-limit</key>
        <true/>
        <key>com.apple.developer.kernel.extended-virtual-addressing</key>
        <true/>
    </dict>
    </plist>
    """

    let entitlements = try PropertyListDecoder().decode(Entitlements.self, from: Data(plist.utf8))
    let all = try entitlements.entitlements()
    let memory = try #require(all.compactMap { $0 as? IncreasedMemoryLimitEntitlement }.first)
    let addressing = try #require(all.compactMap { $0 as? ExtendedVirtualAddressingEntitlement }.first)

    #expect(memory.rawValue)
    #expect(addressing.rawValue)
    #expect(memory.capability.capabilityType.value2 == "INCREASED_MEMORY_LIMIT")
    #expect(addressing.capability.capabilityType.value2 == "EXTENDED_VIRTUAL_ADDRESSING")
    #expect(memory.capability.isFree && addressing.capability.isFree)
    #expect(all.compactMap(\.anyCapability).count == 2)

    let encoded = try PropertyListEncoder().encode(entitlements)
    let dictionary = try #require(
        PropertyListSerialization.propertyList(from: encoded, format: nil) as? [String: Any]
    )
    #expect(dictionary[IncreasedMemoryLimitEntitlement.identifier] as? Bool == true)
    #expect(dictionary[ExtendedVirtualAddressingEntitlement.identifier] as? Bool == true)
}
