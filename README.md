*This project has been created as part of the 42 curriculum by khiidenh.*

Description:
This project is part of the 42 curriculum. The goal is to set up a running WordPress website using Docker, where each
service runs in its own isolated container. The project focuses on understanding how Docker containers work together rather than
the website itself.

Services:
- nginx: web server, entry point to the website.
- wordpress: website files and PHP executor.
- mariadb: database storing all the website data.

Virtual Machines vs Docker
This project uses both Virtual Machine and Docker. The reason why we are using Virtual Machine in this project is that the volumes are bound to the host machine, meaning I would need sudo access to remove those. In addition, nginx uses a privileged port 443 which is not accessible in
host environment. When it comes to the differences between using VM's and Docker. To my understanding, Docker is quite a lot easier to use
when it just comes to creating programs that can run on many different machines. Docker is lighter, requires less space and starts somewhat quickly. VMs are heavier, take more storage and take longer to start.

Secrets vs Environment Variables
Docker secrets are the recommended way to store sensitive credentials. For this project, .env file is used to store both configuration and
credentials as they should already be omitted from the repository from the first place.

Docker Network vs Host Network
Docker Network is a network that connects the containers together so the networking is enabled in isolated environment. Host Network would mean that anyone on host can also connect to these containers which conflicts with the idea of containers being isolated from the host.

Docker Volumes vs Bind Mounts
Volumes store data persistently outside the container. If a container is stopped, the data survives through the rebuild. This project uses bind mounts specifically, which link host directories into containers. This means data is stored on the host filesystem and requires sudo to clean up.


Instructions:
More documentation can be found under DEV_DOC.md and USER_DOC.md. In short, clone the repository, copy it to your Virtual Machine (scp -P 4241 -r /home/khiidenh/Desktop/Inception khiidenh@localhost:/home/khiidenh/Inception), connect
via SSH (ssh localhost -p 4241) and run make from the project root.


Resources:
This project was built by following guides and tutorials as starting point. After this, I reverse-engineered through the entire code and cleaned up the code to my best understanding, while also learning the concepts along the way. AI was used extensively in addition to the guides, to more deeply understand what each piece of code does and why do we need to have it. It was also used to get very clear explanations of the underlying concepts as some part felt quite complex when studying them!
Sources:
https://docs.docker.com/compose/
https://docs.docker.com/build/concepts/dockerfile/
https://github.com/RychkovIurii/inception
https://github.com/Vikingu-del/Inception-Guide
https://github.com/TanjaMenkovic/inception
