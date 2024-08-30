//
//  PMAInfoVIew.swift
//  weatherapp
//
//  Created by Kedan Zha on 8/30/24.
//

import SwiftUI

struct PMAInfoVIew: View {
    var body: some View {
        let PMAInfo = """
About
The Product Manager Accelerator Program is designed to support PM professionals through every stage of their career. From students looking for entry-level jobs to Directors looking to take on a leadership role, our program has helped over hundreds of students fulfill their career aspirations.

Our Product Manager Accelerator community are ambitious and committed. Through our program they have learnt, honed and developed new PM and leadership skills, giving them a strong foundation for their future endeavours.

Learn product management for free today on our YouTube channel
https://www.youtube.com/c/drnancyli?sub_confirmation=1

Interested in PM Accelerator Pro?
Step 1️⃣: Attend the Product Masterclass to learn more about the program details, price, different packages, and stay until the end to get FREE AI Course.

Learn how to create a killer product portfolio 2 two weeks that will help you land any PM job( traditional or AI) even if you were laid off or have zero PM experience

https://www.drnancyli.com/masterclass

Step 2️⃣: Reserve your early bird ticket and submit an application to talk to our Head of Admission

Step 3️⃣: Successful applicants join our PMA Pro community to receive customized coaching!
"""
        VStack{
            Text(PMAInfo)
                .padding()
               
            
        }
    }
}

#Preview {
    PMAInfoVIew()
}
