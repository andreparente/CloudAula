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
    
    
    func saveContact(contact: Contact) {
        
        //Bloco 1: Aqui vamos instanciar a record que usaremos e o respsectivo recordId, que escolhemos usar o nome como chave primária
        
        let recordId = CKRecordID(recordName: contact.name)
        let record = CKRecord(recordType: "Contact", recordID: recordId)
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        
        //Bloco 2: Aqui é o bloco que daremos fetch para ver se o contato já existe - se já existe algum record com o recordId (nome) setado pelo usuário.
        
        publicDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            if error == nil {
                
                //se não deu erro, é porque o contato já existe, não podendo assim ser adicionado, uma notificação é passada então para todos os observadores.
                
                print("Já existe esse contato")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationErrorCadastro"), object: nil)
                
            }
                
            else {
                
                if(fetchedRecord == nil) {
                    
                    //Se entrar aqui, é porque o record ainda não existe, então criaremos finalmente e salvaremos.
                    print("primeira vez que ta criando o usuário")
                    record.setObject(contact.name as CKRecordValue?, forKey: "name")
                    record.setObject(contact.idade as CKRecordValue?, forKey: "age")
                    //essa função setObject, do record, seta qualquer tipo as CKRecordValue, para alguma key já criada no dashboard do Contato.
                    
                    
                    //Bloco 3: Salvar o record.
                    
                    publicDatabase.save(record, completionHandler: { (record, error) -> Void in
                        if (error != nil) {
                            print(error!)
                        }
                        else {
                            //uma vez salvo, sem erros, você adiciona nas suas respectivas variáveis locais, e depois manda uma notification para os observadores.
                            
                            globalContacts.append(Contact(name: contact.name, idade: contact.idade))
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationSuccessCadastroContacts"), object: nil)
                        }
                    })
                }
            }
        }
    }
    
    func addTelephone(telephone: Telephone, contact: Contact) {
        
        //Bloco 1: Aqui vamos instanciar a record que usaremos e o respsectivo recordId, que escolhemos usar o nome como chave primária

      //  let recordId = CKRecordID(recordName: String(telephone.number))
        let record = CKRecord(recordType: "Telephone")
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let contactId = CKRecordID(recordName: contact.name)
        
        
        //Bloco 2: Aqui é o bloco que daremos fetch para ver se o telefone já existe - se já existe algum record com o recordId (nome) setado pelo usuário.

        publicDatabase.fetch(withRecordID: record.recordID) { (fetchedRecord,error) in
            
            if error == nil {
                
                //se não deu erro, é porque o telefone já existe, não podendo assim ser adicionado, uma notificação é passada então para todos os observadores.

                print("Já existe esse telefone")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationErrorCadastroTelephone"), object: nil)
                
            }
                
            else {
                
                if(fetchedRecord == nil) {
                    
                    //Se entrar aqui, é porque o record ainda não existe, então criaremos finalmente e salvaremos.

                    print("primeira vez que ta criando o telefone")
                    record.setObject(telephone.number as CKRecordValue?, forKey: "number")
                    record.setObject(telephone.type as CKRecordValue?, forKey: "type")
                    let telephoneReference = CKReference(recordID: record.recordID, action: .none)
                    
                    contact.references.append(telephoneReference)
                    publicDatabase.save(record, completionHandler: { (record, error) -> Void in
                        if (error != nil) {
                            print(error!)
                        }
                        else {
                            
                            //uma vez salvo, sem erros, você salva agora a referencia desse telefone em todos os outros records que terão uma reference para esse telefone, no caso é apenas um contato.
                            self.saveTelephoneReference(container: container, recordId: contactId, contact: contact, telephoneReference: telephoneReference, telephone: telephone)
                            
                        }
                    })
                }
            }
        }
    }
    
    private func saveTelephoneReference(container: CKContainer, recordId: CKRecordID, contact: Contact, telephoneReference: CKReference, telephone: Telephone) {
        
        container.publicCloudDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            
            if error == nil {
                
                print("o contato existe")
                
                //ao dar fetch no record dos contatos, setamos a lista de reference para a key "telephones" exatamente a List Reference criada no dashboard.
                
                fetchedRecord!.setObject(contact.references as CKRecordValue?, forKey: "telephones")
                
                
                //Salvamos.
                container.publicCloudDatabase.save(fetchedRecord!, completionHandler: { (record, error) -> Void in
                    if (error != nil) {
                        print(error!)
                    } else {
                        
                        //deu certo, adiciona na variavel local e manda a notification para os observers de que foi sucesso.
                        contact.addTelephone(telephone: telephone)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationSuccessCadastroTelephone"), object: nil)
                    }
                })
            }
                
            else {
                print("deu ruim no fetch do contato, ele supostamente não existe")
            }
        }
    }
    
    
    func fetchContacts() {
        
        //instanciamos aqui o container, o database e o predicate, que no nosso caso é apenas true, como se fosse um "select all"
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        
        //A query é instanciada a partir do recordType, ou seja, de qual tabela queremos os dados, e o predicate que queremos usar.
        let query = CKQuery(recordType: "Contact", predicate: predicate)
        
        //esse bloco será executado. ou seja, performQuery.
        publicDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error != nil {
                print(error!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationErrorInternet"), object: nil)
            }
            else {
                
                //como estamos em um projeto pequeno, eu apago todos os dados locais e recupero tudo de novo, não é elegante.. o certo seria recuperar os dados e ver se o que foi recuperado está local, se tiver, não adiciona, se não tiver, adiciona.
                globalContacts.removeAll()
                
                //loop nos resultados da query
                for result in results! {
                    
                    //aqui ja instancio o novo contato com o result.value, ele puxa os dados de um result e nós fazemos a conversão para os tipos que queremos.
                    let newContact = Contact(name: result.value(forKey: "name") as! String, idade: result.value(forKey: "age") as! Int)
                    
                    //aqui eu vejo se o usuário tem alguma referencia/telefone.
                    if let teste = result.object(forKey: "telephones") as? [CKReference] {
                        
                        //adiciono os x telefones dele na variavel local.
                        for telReference in teste {
                            newContact.references.append(telReference)
                            //print(telReference)
                        }
                        
                        //e por isso adiciono o contato no array de contatos local.
                        globalContacts.append(newContact)
                        
                    } else {
                        
                        //deu certo, so nao possui nenhum telefone/referencia de telefone, adiciona assim mesmo
                        globalContacts.append(newContact)
                        print(newContact.name + " nao possui celular")
                    }
                }
                //no fim do for, o vetor estará preenchido com seus respectivos usuários, agora é só mandar uma notificação para os observers.
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
                    
                    //aqui eu crio um vetor de recordId's para usar na operação do fetch.
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
                            
                            //loop nos resultados/telefones que achamos com esses references
                            for (_, result) in records! {
                                
                                //instacia um telefone.
                                let telephone = Telephone(type: result.value(forKey: "type") as! String, number: result.value(forKey: "number") as! Int)
                                //adiciona o telefone ao contato
                                contact.addTelephone(telephone: telephone)
                                //adiciona a referencia do telefone a lista de referencias do contato.
                                contact.references.append(CKReference(recordID: result.recordID, action: .none))
                                //print(telephone.number, telephone.type)
                            }
                            //no fim do loop, voce manda uma notificação dizendo que foi um sucesso.
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationSuccessFetchTelephones"), object: nil)
                        }
                    }
                    
                    //este add é necessário para que esse block de cima seja executado.
                    CKContainer.default().publicCloudDatabase.add(fetchOperation)
                } else {
                    
                    //Não existe nenhum telefone cadastrado. Ok
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationSuccessFetchTelephones"), object: nil)
                }
            }
        }
    }
    
    func deleteTelephone(telephoneToDelete: CKReference, contact: Contact, index: Int) {
        
        print("NOME DO CONTATO QUE TA SENDO DELETADO  ", contact.name)
        let contactRecordId = CKRecordID(recordName: contact.name)
        
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        
        //função usada para deletar alguma record.
        publicDatabase.delete(withRecordID: telephoneToDelete.recordID,completionHandler:
            ({returnRecord, error in
                if error != nil {
                    print(error!)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationDeleteError"), object: nil)
                }
            }))
        
        //removemos também nas variaveis locais.
        contact.references.remove(at: index)
        contact.telephones.remove(at: index)
        
        //damos fetch nas references dos telefones atualizadas
        container.publicCloudDatabase.fetch(withRecordID: contactRecordId) {
            (fetchedRecord,error) in
            print(fetchedRecord!)
            
            if error == nil {
                
                //apos deletar um telefone resetamos e salvamos as referencias, nao tem problema se a lista ficar vazia.
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

    //Função que verifica se o telefone da pessoa está conectada em alguma conta iCloud
    func cloudAvailable()->(Bool) {
        if FileManager.default.ubiquityIdentityToken != nil{
            return true
        }
        else{
            return false
        }
    }
    
    
    //função que pega o ID da Cloud do cadastro da pessoa.
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
}
