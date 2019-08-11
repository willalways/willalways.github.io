---
layout: post
title: Network OSI Model
category: 软件工程
keywords: cyber,network,网络,计算机网络,2019
---

+ [OSI七层模型](http://www.hackerspirit.org/2019/08/06/Network-OSI-Model.html)
+ [物理层](http://www.hackerspirit.org/2019/08/06/Network-OSI-Layer1.html)
+ [数据链路层](http://www.hackerspirit.org/2019/08/06/Network-OSI-Layer2.html)
+ [网络层](http://www.hackerspirit.org/2019/08/06/Network-OSI-Layer3.html)
+ [传输层](http://www.hackerspirit.org/2019/08/06/Network-OSI-Layer4.html)
+ [应用层(会话层+表示层+应用层)](http://www.hackerspirit.org/2019/08/06/Network-OSI-Layer567.html)

## OSI七层模型
OSI模型是一个抽象的网络模型，不单单是针对TCP/IP网络。
可以理解为OSI模型是一个类，而TCP/IP网络是一个实例。

网络模型定义的初衷是节点的互联是趋势，在这种趋势下，节点间的通信就需要一套规范的协议（比如TCP/IP协议簇）达到兼容。
这个OSI网络模型就是指导怎么定义节点互联的协议的。

OSI把网络按分层架构分为7层，分别是物理层，数据链路层，网络层，传输层，会话层，展示层，应用层

![OSI-model-describe](http://www.hackerspirit.org/assets/img/OSI-model-describe.png)

![map-protocol-to-OSI-model](http://www.hackerspirit.org/assets/img/map-protocol-to-OSI-model.png)

## 物理层
The physical layer is responsible for the transmission and reception of unstructured raw data between a device and a physical transmission medium. 

It converts the digital bits into electrical, radio, or optical signals. 

Layer specifications define characteristics such as voltage levels, the timing of voltage changes, physical data rates, maximum transmission distances, modulation scheme, channel access method and physical connectors. This includes the layout of pins, voltages, line impedance, cable specifications, signal timing and frequency for wireless devices. 

Bit rate control is done at the physical layer and may define transmission mode as simplex, half duplex, and full duplex. The components of a physical layer can be described in terms of a network topology. Bluetooth, Ethernet, and USB all have specifications for a physical layer.

简单来说，物理层就是定义一组物理媒介传输规范，比如电压，频率，时许，最大传输距离，传输速率，单工/半双工/全双工通信 等等。

最常见的网线使用RJ45接口，无线网络使用802.11a/b/g/n/ac等都是归属物理层。

## 数据链路层
The data link layer provides node-to-node data transfer—a link between two directly connected nodes. It detects and possibly corrects errors that may occur in the physical layer. It defines the protocol to establish and terminate a connection between two physically connected devices. It also defines the protocol for flow control between them.

IEEE 802 divides the data link layer into two sublayers:<br>
Medium access control (MAC) layer – responsible for controlling how devices in a network gain access to a medium and permission to transmit data.<br>
Logical link control (LLC) layer – responsible for identifying and encapsulating network layer protocols, and controls error checking and frame synchronization.

物理层只管把二进制数据通过物理媒介传输出去，不管数据内容。<br>
特别注意“two directly connected nodes”这里说链路层只管两个直接节点的通信。<br>
数据链路层其中一个任务是控制节点对媒介的利用，还有一个任务是校验物理层媒介传输是否有误。
当然了，控制的基础是每个节点都有一个身份表示，最常见的应该就是MAC地址了，这个MAC地址其实也是Medium access control (MAC) layer定义的。

常见的数据链路层协议有：802.3 Ethernet, 802.11 Wi-Fi, and 802.15.4 ZigBee，Point-to-Point Protocol (PPP)等

我们通过wireshark抓包看到，所有数据包都是以源MAC地址开始的，实际上，真正传输的数据包应该还有一层封装，我们看到的其实是数据链路层的帧
以IEEE 802.3 Frame Fields为例
|Preamble|Destination Address|Source Address|Length|802.2 Header and Data|Frame Check Sequence|
|-|-|-|-|-|-|
|8 bytes|6 bytes|6 bytes|2 bytes|46 - 1500 bytes|4 bytes|

## 网络层
The network layer provides the functional and procedural means of transferring variable length data sequences (called packets) from one node to another connected in "different networks". A network is a medium to which many nodes can be connected, on which every node has an address and which permits nodes connected to it to transfer messages to other nodes connected to it by merely providing the content of a message and the address of the destination node and letting the network find the way to deliver the message to the destination node, possibly routing it through intermediate nodes. 

If the message is too large to be transmitted from one node to another on the data link layer between those nodes, the network may implement message delivery by splitting the message into several fragments at one node, sending the fragments independently, and reassembling the fragments at another node. It may, but does not need to, report delivery errors.

Message delivery at the network layer is not necessarily guaranteed to be reliable; a network layer protocol may provide reliable message delivery, but it need not do so.

网络层按照上面的描述，主要分为三个核心部分
+ 一： 网络层是节点组成的网络，抽象了数据链路层，无论是使用802.3 Ethernet, 802.11 Wi-Fi, 还是token ring都可以在网络层通信
+ 二： 网络层负责把数据链路层太大的数据包切分成小的数据包传输，目标节点负责把切分的数据包重新组包成完整数据包
+ 三： 网络层通信传输不必要是可信的，也就是说一个节点想把数据包发送给另外一个节点，协议可以定义忽略目标节点是否真实收到数据包

常见的网络层协议有IP，ICMP，IGMP，IPsec等

## 传输层
TODO

## 应用层
The application layer is the OSI layer closest to the end user, which means both the OSI application layer and the user interact directly with the software application. This layer interacts with software applications that implement a communicating component. Such application programs fall outside the scope of the OSI model. 

Application-layer functions typically include identifying communication partners, determining resource availability, and synchronizing communication. When identifying communication partners, the application layer determines the identity and availability of communication partners for an application with data to transmit. 

The most important distinction in the application layer is the distinction between the application-entity and the application. For example, a reservation website might have two application-entities: one using HTTP to communicate with its users, and one for a remote database protocol to record reservations. Neither of these protocols have anything to do with reservations. That logic is in the application itself. The application layer per se has no means to determine the availability of resources in the network.

上面一段话可以理解为
+ 应用层和用户都是直接和应用程序直接交互的
+ 应用程序负责对数据发送方的身份认证，数据的可用性以及数据同步等
+ 区分应用程序和应用实体，一个应用可能有多个应用实体，比如一个预订网站，一个应用实体是Web服务（HTTP协议），另一个实体是远程数据库访问（Remote Database Access）服务，他们直接的逻辑关系是完全有应用程序决定的，不属于应用层的定义范围。

常见的应用层协议有HTTP，FTP，SNMP等

## TCP/IP协议簇
互联网协议套件（英语：Internet Protocol Suite，缩写IPS）是一个网络通信模型，以及一整个网络传输协议家族，为网际网络的基础通信架构。它常被通称为TCP/IP协议族（英语：TCP/IP Protocol Suite，或TCP/IP Protocols），简称TCP/IP。因为该协议家族的两个核心协议：TCP（传输控制协议）和IP（网际协议），为该家族中最早通过的标准。由于在网络通讯协议普遍采用分层的结构，当多个层次的协议共同工作时，类似计算机科学中的堆栈，因此又被称为TCP/IP协议栈（英语：TCP/IP Protocol Stack）。这些协议最早发源于美国国防部（缩写为DoD）的ARPA网项目，因此也被称作DoD模型（DoD Model）。这个协议族由互联网工程任务组（Internet Engineering Task Force (IETF)）负责维护。

|Layer|Protocols|
|-|-|
|Application Layer|DHCP, DNS, FTP, HTTP, HTTPS, IMAP, LDAP, MQTT, NTP, POP, RTP, RTSP, RIP, SIP, SMTP, SNMP, SSH, Telnet, TLS/SSL, XMPP|
|Transport Layer|TCP, UDP, SCTP, RSVP, DCCP|
|Internet Layer|IP(v4, v6), ICMP, IGMP, IPsec|
|Link Layer|MAC(Ethernet, Wi-Fi, DSL), ARP, PPP, L2TP, Token Ring|


## 引用
1 [https://en.wikipedia.org/wiki/OSI_model](https://en.wikipedia.org/wiki/OSI_model)
2 [ethernet_protocol](http://teachweb.milin.cc/datacommunicatie/tcp_osi_model/data_link_layer/ethernet_protocol.htm)
3 [Internet_protocol_suite](https://en.wikipedia.org/wiki/Internet_protocol_suite)
4 《数据通信与网络》（美）Behrouz A.Forouzan 
