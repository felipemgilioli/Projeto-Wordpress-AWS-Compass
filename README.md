# Projeto-Wordpress-AWS-Compass
# WordPress em Alta Disponibilidade na AWS

*Projeto de infraestrutura para hospedar uma aplicação WordPress escalável, resiliente e tolerante a falhas, utilizando os principais serviços gerenciados da nuvem AWS.*

![Tecnologia](https://img.shields.io/badge/tecnologia-AWS-orange)
![CMS](https://img.shields.io/badge/CMS-WordPress-blue)

---

## 📖 Sumário

* Sobre o Projeto
* Arquitetura da Solução
* Componentes na AWS
* Etapas de Implementação

---

## 🎯 Sobre o Projeto

Este projeto tem como objetivo desenvolver competências práticas em **infraestrutura como código, provisionamento de recursos em nuvem e arquiteturas resilientes**. A meta é implantar a plataforma WordPress na nuvem AWS de forma escalável e tolerante a falhas, garantindo máximo desempenho e disponibilidade.

Essa arquitetura simula um ambiente de produção real, no qual interrupções não podem causar indisponibilidade da aplicação. O uso de serviços gerenciados permite focar na lógica de implementação e escalabilidade, sem a necessidade de gerenciar manualmente servidores de banco de dados ou sistemas de arquivos distribuídos.

---

## Diagrama da Arquitetura

A imagem abaixo ilustra a arquitetura implementada, demonstrando como os serviços da AWS interagem para criar uma solução robusta.

![Figura 01: Diagrama Wordpress](https://github.com/felipemgilioli/Projeto-Wordpress-AWS-Compass/blob/main/images/Arquitetura-Projeto.png)


A aplicação WordPress será distribuída em instâncias **EC2** por meio de um **Auto Scaling Group (ASG)**, com balanceamento de carga fornecido por um **Application Load Balancer (ALB)**. O armazenamento de arquivos (uploads, mídias) será centralizado e compartilhado através do **Amazon Elastic File System (EFS)**, enquanto os dados da aplicação serão armazenados com o **Amazon RDS**.

---

## 🛠️ Componentes na AWS

A solução é composta pelos seguintes recursos provisionados e configurados na AWS:

#### VPC Personalizada
* **2 Subnets públicas** (para o Application Load Balancer).
* **4 Subnets privadas** (para as instâncias EC2 e o banco de dados RDS).
* Configuração de **Route Tables**, **Internet Gateway (IGW)** e **NAT Gateway**.

#### Amazon RDS
* Instância de banco de dados **Multi-AZ** com MySQL/MariaDB para alta disponibilidade.
* Nível de segurança aprimorado com **Security Group** e alocação em **subnets privadas**.

#### Amazon EFS
* Sistema de arquivos compartilhado, montado automaticamente nas instâncias EC2 via `user-data`.
* Utilizado para armazenar de forma centralizada os arquivos enviados ao WordPress (fotos, vídeos, etc.).

#### Auto Scaling Group com EC2
* **Script de bootstrap (`user-data`)** para automação da configuração inicial das instâncias.
* **Escalonamento automático** baseado no uso de CPU para lidar com variações de tráfego.

#### Application Load Balancer
* Distribui o tráfego de entrada de forma inteligente entre as instâncias EC2 ativas.
* Configuração adequada de **Health Check** para garantir que o tráfego seja enviado apenas para instâncias saudáveis.

---

## 🚀 Etapas de Implementação

O projeto foi construído seguindo as etapas abaixo:

1.  **Análise Local:** Rodar o WordPress via Docker para conhecer a aplicação base.
2.  **Criar a VPC:**
    * 2 Availability Zones (AZs).
    * 4 subnets (2 públicas, 2 privadas).
    * IGW para acesso à internet nas subnets públicas.
    * NAT Gateway para permitir que recursos em subnets privadas acessem a internet.
3.  **Criar o RDS:**
    * Provisionar o banco de dados MySQL/MariaDB.
    * Configurar o Security Group para permitir acesso apenas das instâncias EC2.
4.  **Criar o EFS:**
    * Provisionar o sistema de arquivos NFS.
    * Configurar as permissões no Security Group para montagem nas instâncias EC2.
5.  **Criar o Launch Template:**
    * Definir um modelo de lançamento para as instâncias EC2.
    * Incluir um script `user-data` que instala o WordPress, monta o EFS e configura a conexão com o banco de dados na inicialização.
6.  **Criar o Auto Scaling Group:**
    * Associar ao Launch Template criado.
    * Configurar para operar nas subnets privadas.
7.  **Criar o Application Load Balancer:**
    * Associar às subnets públicas.
    * Configurar para encaminhar o tráfego para o Auto Scaling Group.

---

