//
//  SDCLogParser.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/19/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation

/*  The format is as follow: $BNRDD,0210,2013-04-11T05:40:51Z,35,0,736,A,3516.1459,N,13614.9700,E,73.50,A,125,0*64

0 - Header : $BNRDD
1 - Device ID : Device serial number. 0210
2 - Date : Date formatted according to iso-8601 standard. Usually uses GMT. 2013-04-11T05:40:51Z
3 - Radiation 1 minute : number of pulses given by the Geiger tube in the last minute. 35 (cpm)
4 - Radiation 5 seconds : number of pulses given by the Geiger tube in the last 5 seconds. 0
5 - Radiation total count : total number of pulses recorded since startup. 736
6 - Radiation count validity flag : 'A' indicates the counter has been running for more than one minute and the 1 minute count is not zero. Otherwise, the flag is 'V' (void). A
7 - Latitude : As given by GPS. The format is ddmm.mmmm where dd is in degrees and mm.mmmm is decimal minute. 3516.1459
8 - Hemisphere : 'N' (north), or 'S' (south). N
9 - Longitude : As given by GPS. The format is dddmm.mmmm where ddd is in degrees and mm.mmmm is decimal minute. 13614.9700
10- East/West : 'W' (west) or 'E' (east) from Greenwich. E
11- Altitude : Above sea level as given by GPS in meters. 73.50
12- GPS validity : 'A' ok, 'V' invalid. A
13- HDOP : Horizontal Dilution of Precision (HDOP), relative accuracy of horizontal position. 125
14- Checksum: 0*64

*/

extension String {
    func parseMeasurementData() -> Dictionary<String, AnyObject>? {
        guard self.hasPrefix("$BNRDD") else {
            return nil
        }
        
        let dataArray       = self.componentsSeparatedByString(",")
        
        // Incomplete data
        guard dataArray.count == 15 else {
            return nil
        }
        
        var dataDictionary: Dictionary<String, AnyObject> = Dictionary()
        
        dataDictionary["data"]              = self
        dataDictionary["date"]              = dataArray[2].dateInUTC()
        dataDictionary["deviceId"]          = dataArray[1]
        dataDictionary["cpm"]               = Int(dataArray[3])!
        dataDictionary["dataValidity"]      = dataArray[6] == "A"
        dataDictionary["latitude"]          = dataArray[7].decimalLatitude(dataArray[8])
        dataDictionary["longitude"]         = dataArray[9].decimalLongitude(dataArray[10])
        dataDictionary["altitude"]          = Double(dataArray[11])!
        dataDictionary["gpsValidity"]       = dataArray[12] == "A"
        dataDictionary["hdop"]              = Int(dataArray[13])!
        
        return dataDictionary
    }
    
    // Adjust degree and minutes format latitude format to decimal
    private func decimalLatitude(latitudeHemisphere: String) -> Double {
        let index       = self.startIndex.advancedBy(2)
        let degree      = Double(self.substringToIndex(index))!
        let minutes     = Double(self.substringFromIndex(index))!
        let latitude    = Double(degree + minutes / 60)
        
        return latitudeHemisphere == "S" ? -latitude : latitude
    }
    
    // Adjust degree and minutes format latitude format to decimal
    private func decimalLongitude(longitudeHemisphere: String) -> Double {
        let index       = self.startIndex.advancedBy(3)
        let degree      = Double(self.substringToIndex(index))!
        let minutes     = Double(self.substringFromIndex(index))!
        let longitude   = Double(degree + minutes / 60)
        
        return longitudeHemisphere == "W" ? -longitude : longitude
    }
    
    // Parse a date with UTC formatting
    private func dateInUTC() -> NSDate {
        let dateStringFormatter         = NSDateFormatter()
        dateStringFormatter.dateFormat  = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateStringFormatter.timeZone    = NSTimeZone(name: "UTC")
        
        if let date = dateStringFormatter.dateFromString(self) {
            return date
        }
        
        return NSDate()
    }
}