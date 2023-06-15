//
//  ImagenViewController.swift
//  MedinaSnapchat
//
//  Created by Mac 08 on 7/06/23.
//

import UIKit
import AVFoundation
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate {
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    
    var audioRecorder: AVAudioRecorder!
    var audioID = NSUUID().uuidString
    var audioURL: URL?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    @IBOutlet weak var grabarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData = imageView.image?.jpegData(compressionQuality: 0.50)
        let cargarImagen = imagenesFolder.child("\(imagenID).jpg")
        cargarImagen.putData(imagenData!, metadata: nil) { (metadata, error) in
            if error != nil {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen.", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrió un error al subir imagen:")
                return
            } else {
                cargarImagen.downloadURL(completion: { (url, error) in
                    guard let imagenURL = url?.absoluteString else {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen", accion: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrió un error al obtener información de imagen")
                        return
                    }
                    
                    if let audioURL = self.audioURL {
                        let audiosFolder = Storage.storage().reference().child("audios")
                        let cargarAudio = audiosFolder.child("\(self.audioID).m4a")
                        cargarAudio.putFile(from: audioURL, metadata: nil) { (metadata, error) in
                            if let error = error {
                                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir el audio. Verifica su conexión a internet y vuelva a intentarlo.", accion: "Aceptar")
                                self.elegirContactoBoton.isEnabled = true
                                print("Ocurrió un error al subir el audio: \(error)")
                                return
                            }
                            
                            cargarAudio.downloadURL { (url, error) in
                                guard let audioURL = url?.absoluteString else {
                                    self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información del audio", accion: "Cancelar")
                                    self.elegirContactoBoton.isEnabled = true
                                    print("Ocurrió un error al obtener información del audio")
                                    return
                                }
                                
                                let snap = ["from": Auth.auth().currentUser?.email, "descripcion": self.descripcionTextField.text!, "imagenURL": imagenURL, "audioURL": audioURL]
                                Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").childByAutoId().setValue(snap) { (error, ref) in
                                    if let error = error {
                                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al guardar el snap en Firebase. Verifica su conexión a internet y vuelva a intentarlo.", accion: "Aceptar")
                                        print("Ocurrió un error al guardar el snap en Firebase: \(error)")
                                    } else {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    } else {
                        let snap = ["from": Auth.auth().currentUser?.email, "descripcion": self.descripcionTextField.text!, "imagenURL": imagenURL]
                        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").childByAutoId().setValue(snap) { (error, ref) in
                            if let error = error {
                                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al guardar el snap en Firebase. Verifica su conexión a internet y vuelva a intentarlo.", accion: "Aceptar")
                                print("Ocurrió un error al guardar el snap en Firebase: \(error)")
                            } else {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(audioID).m4a")
        audioURL = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            grabarButton.setTitle("Detener", for: .normal)
        } catch {
            mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al iniciar la grabación de audio", accion: "Aceptar")
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            grabarButton.setTitle("Grabar", for: .normal)
        } else {
            grabarButton.setTitle("Error", for: .normal)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnCANCELOK)
        present(alerta, animated: true, completion: nil)
    }
}
