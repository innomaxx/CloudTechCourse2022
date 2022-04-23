<details>
<summary>1) Login via SSH with password</summary>

![](Task_1/1.png)

<br/>

![](Task_1/2.png)

<br/>

![](Task_1/3.png)

<br/>

![](Task_1/4.png)

<br/>

![](Task_1/5.png)

</details>
<br/>

<details>
<summary>2) Login via SSH with keys</summary>

![](Task_2/1.png)

<br/>

![](Task_2/2.png)

<br/>

![](Task_2/3.png)

<br/>

![](Task_2/4.png)

<br/>

![](Task_2/5.png)

<br/>

![](Task_2/6.png)

<br/>

![](Task_2/7.png)

</details>

<br/>

<details>
<summary>3) Change default SSH port</summary>

![](Task_3/1.png)

<br/>

![](Task_3/2.png)

<br/>

![](Task_3/3.png)

<br/>

![](Task_3/4.png)

</details>

<br/>

<details>
<summary>What is port forwarding?</summary>

<p>
SSH port forwarding is a mechanism in SSH for tunneling application ports from the client machine to the server machine, or vice versa. 
It can be used for adding encryption to legacy applications, going through firewalls,
and some system administrators and IT professionals use it for opening backdoors into the internal network from their home machines. 
It can also be abused by hackers and malware to open access from the Internet to the internal network.
</p>

<p>
Command:

```
ssh -L 80:intra.example.com:80 gw.example.com
```
</p>

![](port-forwarding.png)
</details>