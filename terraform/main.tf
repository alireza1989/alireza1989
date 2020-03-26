// Configure the Google Cloud provider
provider "google" {
 credentials = file("YOUR KEY FILE PATH")
 project     = "YOUR PROJECT NAME"
 region      = "us-central1"
}


// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}


resource "google_compute_instance" "default" {
    name = "flask-vm-${random_id.instance_id.hex}"
    machine_type = "n1-standard-1" 
    zone = "us-central1-a"

    boot_disk {
        initialize_params {
            image = "ubuntu-1804-bionic-v20200317"
        }
    }

    // Make sure flask is installed on all new instances for later steps
    metadata_startup_script = "sudo apt-get update"


    network_interface {
        network = "default"
        access_config {
            // Include this section to give the VM an external ip address
        }
    }

    metadata = {
        ssh-keys = "wspadmin:${file("~/.ssh/id_rsa.pub")}"
    }

}

resource "google_compute_firewall" "default" {
 name    = "flask-app-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["5000"]
 }
}

// A variable for extracting the external ip of the instance
output "ip" {
 value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}