//
//  DAO.swift
//  CloudAula
//
//  Created by Andre Machado Parente on 07/03/17.
//  Copyright © 2017 Andre Machado Parente. All rights reserved.
//

import Foundation
import CloudKit

class DAO {
    
    
    func addContact(contact: Contact) {
        
        let recordId = CKRecordID(recordName: contact.name)
        let record = CKRecord(recordType: "Contact", recordID: recordId)
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        
        publicDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            if error == nil {
                
                print("Já existe esse Contato")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationErrorCadastro"), object: nil)
                
            }
                
            else {
                
                if(fetchedRecord == nil) {
                    
                    print("primeira vez que ta criando o usuário")
                    record.setObject(contact.name as CKRecordValue?, forKey: "name")
                    record.setObject(contact.idade as CKRecordValue?, forKey: "age")
                    
                    publicDatabase.save(record, completionHandler: { (record, error) -> Void in
                        if (error != nil) {
                            print(error)
                        }
                        else{
                            globalContacts.append(Contact(name: contact.name, idade: contact.idade))
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationSuccessCadastroContacts"), object: nil)
                        }
                    })
                }
            }
        }
    }
    
    func addTelephone(telephone: TelephoneNumber, contact: Contact) {
        
        let recordId = CKRecordID(recordName: String(telephone.number))
        let record = CKRecord(recordType: "Telephone")
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let contactId = CKRecordID(recordName: contact.name)
        
        
        
        publicDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            if error == nil {
                
                print("Já existe esse telefone")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationErrorCadastroTelephone"), object: nil)
                
            }
                
            else {
                
                if(fetchedRecord == nil) {
                    
                    print("primeira vez que ta criando o telefone")
                    record.setObject(telephone.number as CKRecordValue?, forKey: "number")
                    record.setObject(telephone.type as CKRecordValue?, forKey: "type")
                    let telephoneReference = CKReference(recordID: record.recordID, action: .none)
                    
                    contact.references.append(telephoneReference)
                    publicDatabase.save(record, completionHandler: { (record, error) -> Void in
                        if (error != nil) {
                            print(error)
                        }
                        else {
                            
                            
                            self.saveTelephoneReference(container: container, recordId: contactId, contact: contact, telephoneReference: telephoneReference, telephone: telephone)
                            
                        }
                    })
                }
            }
        }
    }
    
    func saveTelephoneReference(container: CKContainer, recordId: CKRecordID, contact: Contact, telephoneReference: CKReference, telephone: TelephoneNumber) {
        
        container.publicCloudDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            
            if error == nil {
                
                print("o contato existe")
                
                //  print("---------------------- Referencia dos gastos: ", user.arrayGastos)
                fetchedRecord!.setObject(contact.references as CKRecordValue?, forKey: "telephones")
                
                container.publicCloudDatabase.save(fetchedRecord!, completionHandler: { (record, error) -> Void in
                    if (error != nil) {
                        print(error!)
                    }
                })
                
                contact.addTelephone(telephone: telephone)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationSuccessCadastroTelephone"), object: nil)
                
            }
                
            else {
                
                //    NSNotificationCenter.defaultCenter().postNotificationName("notificationErrorAddCategory", object: nil)
                print("DEU RUIM FUDEU")
            }
        }
    }
    
    
    func fetchContacts() {
        
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Contact", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error != nil {
                print(error)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationErrorInternet"), object: nil)
            }
            else {
                
                globalContacts.removeAll()
                for result in results! {
                    let newContact = Contact(name: result.value(forKey: "name") as! String, idade: result.value(forKey: "age") as! Int)
                    if let teste = result.object(forKey: "telephones") as? [CKReference] {
                        for telReference in teste {
                            newContact.references.append(telReference)
                            print(telReference)
                        }
                        globalContacts.append(newContact)
                        
                    } else {
                        //deu certo, so nao possui nenhum telefone/referencia de telefone
                        globalContacts.append(newContact)
                        print(newContact.name + " nao possui celular")
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationSuccessFetchContacts"), object: nil)
            }
        }
    }
    
    func fetchTelephonesFromContact(contact: Contact) {
        
        var telephonesRecordIds: [CKRecordID] = []
        
        let recordId = CKRecordID(recordName: contact.name)
        let container = CKContainer.default()
        
        container.publicCloudDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            // print(fetchedRecord)
            
            if error == nil {
                
                if let teste = fetchedRecord!.object(forKey: "telephones") as? [CKReference] {
                    print("quantidade de telefones registrados: ", teste.count)
                    
                    
                    for telReference in teste {
                        telephonesRecordIds.append(telReference.recordID)
                    }
                    
                    let fetchOperation = CKFetchRecordsOperation(recordIDs: telephonesRecordIds)
                    fetchOperation.fetchRecordsCompletionBlock = {
                        records, error in
                      //  print("RECORDS ", records)
                        if error != nil {
                            print(error!)
                            
                            
                        } else {
                            
                            contact.telephones.removeAll()
                            contact.references.removeAll()
                            
                            for (_, result) in records! {
                                
                                let telephone = TelephoneNumber(type: result.value(forKey: "type") as! String, number: result.value(forKey: "number") as! Int)
                                contact.addTelephone(telephone: telephone)
                                contact.references.append(CKReference(recordID: result.recordID, action: .none))
                                print(telephone.number, telephone.type)
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationSuccessFetchTelephones"), object: nil)
                        }
                    }
                    
                    CKContainer.default().publicCloudDatabase.add(fetchOperation)
                }
            }
        }
    }
    
    
    func cloudAvailable()->(Bool) {
        if FileManager.default.ubiquityIdentityToken != nil{
            return true
        }
        else{
            return false
        }
    }
    
    
    func getId(_ complete: @escaping (_ instance: CKRecordID?, _ error: NSError?) -> ()) {
        let container = CKContainer.default()
        container.fetchUserRecordID() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(nil, error as NSError?)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationErrorGetId"), object: nil)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(recordID, nil)
                
                
                // NSNotificationCenter.defaultCenter().postNotificationName("notificationSucessGetId", object: nil)
            }
        }
    }
    
    func deleteTelephone(telephoneToDelete: CKReference, contact: Contact, index: Int) {
        
        print("NOME DO CONTATO QUE TA SENDO DELETADO  ", contact.name)
        let contactRecordId = CKRecordID(recordName: contact.name)
        
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        
        publicDatabase.delete(withRecordID: telephoneToDelete.recordID,completionHandler:
            ({returnRecord, error in
                if error != nil {
                    print(error!)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationDeleteError"), object: nil)
                }
            }))
        contact.references.remove(at: index)
        contact.telephones.remove(at: index)
        container.publicCloudDatabase.fetch(withRecordID: contactRecordId) {
            (fetchedRecord,error) in
            print(fetchedRecord!)
            
            if error == nil {
                print("---------------------- Referencia dos telefones atualizadas: ", contact.references)
                fetchedRecord!.setObject(contact.references as CKRecordValue?, forKey: "telephones")
                
                container.publicCloudDatabase.save(fetchedRecord!, completionHandler: { (record, error) -> Void in
                    if (error != nil) {
                        print(error!)
                    }
                })
            }
        }
    }
    
    func deleteContact(contact: Contact, index: Int) {
        
        print("NOME DO CONTATO QUE TA SENDO DELETADO  ", contact.name)
        let contactRecordId = CKRecordID(recordName: contact.name)
        
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        
        publicDatabase.delete(withRecordID: contactRecordId,completionHandler:
            ({returnRecord, error in
                if error != nil {
                    print(error!)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationDeleteError"), object: nil)
                } else {
                    print("Deu certo")
                    globalContacts.remove(at: index)
                }
            }))
        

//        container.publicCloudDatabase.fetch(withRecordID: contactRecordId) {
//            (fetchedRecord,error) in
//            print(fetchedRecord!)
//            
//            if error == nil {
//                print("---------------------- contatos que sobraram: ", globalContacts)
//                fetchedRecord!.setObject(contact.references as CKRecordValue?, forKey: "telephones")
//                
//                container.publicCloudDatabase.save(fetchedRecord!, completionHandler: { (record, error) -> Void in
//                    if (error != nil) {
//                        print(error!)
//                    }
//                })
//            }
//        }

    }
    
}
