//
//  ElegirUsuarioViewController.swift
//  MedinaSnapchat
//
//  Created by Mac 08 on 9/06/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ElegirUsuarioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usuarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let usuario = usuarios[indexPath.row]
        cell.textLabel?.text = usuario.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let usuario = usuarios[indexPath.row]
        let snap = Snap()
        snap.from = Auth.auth().currentUser?.email ?? ""
        snap.descripcion = descrip
        snap.imagenURL = imagenURL
        snap.imagenID = imagenID
        snap.audioURL = audioURL
        snap.audioID = audioID
        
        let snapRef = Database.database().reference().child("usuarios").child(usuario.uid).child("snaps").childByAutoId()
        snapRef.setValue(snap.toDictionary()) { (error, ref) in
            if let error = error {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al enviar el snap. Verifica tu conexión a internet y vuelve a intentarlo.", accion: "Aceptar")
                print("Ocurrió un error al enviar el snap: \(error)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBOutlet weak var listaUsuarios: UITableView!
    var usuarios: [Usuario] = []
    var imagenURL = ""
    var descrip = ""
    var imagenID = ""
    var audioURL = ""
    var audioID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listaUsuarios.delegate = self
        listaUsuarios.dataSource = self
        
        Database.database().reference().child("usuarios").observe(DataEventType.childAdded) { (snapshot) in
            print(snapshot)
            
            let usuario = Usuario()
            usuario.email = (snapshot.value as! NSDictionary)["email" ] as! String
            usuario.uid = snapshot.key
            self.usuarios.append(usuario)
            self.listaUsuarios.reloadData()
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnAceptar = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnAceptar)
        present(alerta, animated: true, completion: nil)
    }
}
