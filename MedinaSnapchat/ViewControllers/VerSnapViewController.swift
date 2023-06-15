//
//  VerSnapViewController.swift
//  MedinaSnapchat
//
//  Created by Mac 08 on 14/06/23.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import AVFAudio
import AVFoundation

class VerSnapViewController: UIViewController {

    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var snap: Snap?
    var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var reproducirButton: UIButton!
    
    @IBAction func ReproducirTapped(_ sender: Any) {
        if let audioURLString = snap?.audioURL, let audioURL = URL(string: audioURLString) {
                    downloadAndPlayAudio(from: audioURL)
                }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            lblMensaje.text = "Mensaje: " + (snap?.descripcion ?? "")
            imageView.sd_setImage(with: URL(string: snap?.imagenURL ?? ""), completed: nil)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            if let snapID = snap?.id {
                Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snapID).removeValue()
            }
            
            if let imagenID = snap?.imagenID {
                Storage.storage().reference().child("imagenes").child("\(imagenID).jpg").delete { (error) in
                    if let error = error {
                        print("Error al eliminar la imagen: \(error)")
                    } else {
                        print("Se eliminó la imagen correctamente")
                    }
                }
            }
        }
        
        private func downloadAndPlayAudio(from url: URL) {
            URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error al descargar el audio: \(error?.localizedDescription ?? "")")
                    return
                }
                
                do {
                    self?.audioPlayer = try AVAudioPlayer(data: data)
                    self?.audioPlayer?.play()
                } catch {
                    print("Error al reproducir el audio: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
