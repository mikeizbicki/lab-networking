# Lab: Networking

In this lab, you will build a small webserver on the lambda server.
The purpose is to introduce you to networking concepts that you will need for working with docker.

Parts 0-1 of this lab don't require a partner, but part 2 will.
I encourage you to work with a partner throughout the whole lab.

## Part 0: terminal-based web client

Any task that you can do without the terminal can be done with the terminal,
including browsing the web.
[Links](https://en.wikipedia.org/wiki/Links_(web_browser)) is one of the most popular command line web browsers.
Login to the lambda server, and run the command
```
$ links http://www.phrack.org
```
Phrack is an old-school hacker zine.
Issue 7, article 3 has the famous "hacker manifesto",
and you should try to browse to it and open it in links.

> **HINT:**
> The up/down arrows take you to the next link,
> but there's a lot of links on a page,
> so moving to the correct link can take a long time.
> Use the `/` key to search for text to navigate the webpage faster.
> Press `q` to quit.

Browsing the web this way is unfortunately rather inconvenient,
and so you may be tempted to ask why would anyone do it?
The simplest answer is that many people must use command line web browsers due to physical disability.
For example, the famous physicist Stephen Hawking had [Lou Gehrig's disease](https://en.wikipedia.org/wiki/Motor_neurone_disease).

<img src=img/hawking.webp width=400px />

He could not use a mouse,
and so could not use a traditional web browser to browse the internet,
and had to use a terminal browser like links designed to work with only the keyboard.

In order to make your webpages accessible to people like Hawking,
it is good practice to test your webpages in the links browser.
And the Americans with Disabilities Act (ADA) actually requires that large companies and government agencies do this.
The [website ada.gov provides detailed guidance](https://www.ada.gov/resources/web-guidance/#when-the-ada-requires-web-content-to-be-accessible) on exactly which companies are required by law to have accessible websites,
and what steps web developers must take to conform to those guidelines.

<!--
### Part 0.a: Ports

Run the command
```
$ links http://phrack.org:80
```
You should connect to the Phrack magazine webpage exactly like you did before.

The `:80` in the url above is called the *port*.
Every computer has 65536 (i.e. $2^{16}$) "ports" that it can use for internet connections.
If no port is specified, then the `http://` protocol defaults to using port 80.

### Part 0.b: The Lambda Server Web Server
-->

Another reason to use the links browser is that we can run it on remote machines and access web servers that our laptop doesn't have direct access to.
For example, run the command
```
$ links http://10.253.1.15:5000
```
You should see a simple "Hello World" webpage get displayed in the links browser.
But now visit the same url <http://10.253.1.15:5000> in firefox on your laptop.
You should get an error about being unable to connect.
This webpage is internal to the CMC network, and IT has created firewall rules that prevent outsiders from viewing it.

> **Aside:**
> The GNU Project argues that Google Chrome and Apple Safari are malware.
> Google and Apple censor what you can see online, spy on the websites you visit, report "bad" websites to authoritarian governments, and provide backdoors for other people to use your computer.
> GNU maintains a [detailed list of infractions for Google here](https://www.gnu.org/proprietary/malware-google.en.html) and for [Apple here](https://www.gnu.org/proprietary/malware-apple.en.html).
> For this reason, I use firefox to browse the web.
> I also recommend the [ublockorigin](https://ublockorigin.com/) adblocker.

Before we learn how to bypass this firewall, it will be useful to review some basic networking.
In the url above, 
the `http://` is called the *scheme*,
and this identifies that you are connecting to a webserver (and not, e.g. a ssh server).
The `10.253.1.15` is called an *IP address*,
and this identifies which computer we are connecting to.
The `:5000` is a *port*,
and every computer has 65536 (i.e. $2^{16}$) ports that it can listen for connections on.

> **Aside:**
> You may never have seen a url with a port specification before.
> This is because all schemes have default ports associated with them,
> and if a service is hosted on the default port,
> then no port is needed.
> The default port for http is 80, and so the url `http://google.com` is equivalent to `http://google.com:80`.

An IP address can host many different webservers as long as each uses a different port.
Another webserver is listening on port 5001 of the same IP address.
You can access it by running
```
$ links http://10.253.1.15:5001
```
And you will be greeted with an "Hola Mundo" message.

## Part 1: port forwarding

[Port forwarding](https://en.wikipedia.org/wiki/Port_forwarding) is a way to connect to ports (and thus webpages) hidden behind a firewall.
It is commonly used to bypass the [Great Firewall of China](https://en.wikipedia.org/wiki/Great_Firewall) and other forms of censorship.
You will use it in order to view the webpage <http://10.253.1.15:5000> directly on your laptop in firefox.

You enable port forwarding by modifying the `ssh` command you use to connect to the lambda server.
Log out, then re-login with the command
```
$ ssh <username>@lambda.compute.cmc.edu -p 5055 -L localhost:8080:10.253.1.15:5000
```
The `-L localhost:8080:10.253.1.15:5000` is what enables port forwarding.
This argument tells ssh to connect the address `localhost:8080` on your computer to `10.253.1.15:5000` on the lambda server.
You can now visit  <http://localhost:8080> in firefox,
and you will be connected to the webpage.

> **Note:**
> You should notice the webpage renders differently in firefox than in links.
> (Links doesn't display gifs.)
> If you were to inspect the HTML, you would see they are the same webpage.

## Part 2: a terminal-based web server

Now we will create a simple web server using shell commands.
The purpose of this exercise is to help you get comfortable with ports and port forwarding.
We will be using many different web services in this course,
and you will need to be an expert in port forwarding in order to get them to talk to each other correctly.

### Part 2.a: `netcat` basics

The `netcat` command can be used to send messages over the network.
(You should think of `netcat` as like `cat`, but for the network instead of files.)
By default, `netcat` connects to an already running server.
Whatever it receives on `stdin` gets sent to the server,
and whatever it receives back from the server it prints to `stdout`.
For example, if you run the command
```
$ netcat localhost 5000 <<EOF
GET /

EOF
```
You should see a bunch of HTML printed,
which is the html that generated the "Hello World" / rickroll webpage.
The here document
```
GET /

```
is the HTTP command for fetching the root webpage of the server.
The `localhost 5000` means that netcat will connect to the current computer at port 5000.

> **Note:**
> `localhost` is a special *hostname*, which is like a shortcut for an IP address.
> `localhost` always refers to the IP address of the machine that you are currently on.
> When you are using firefox on your laptop, `localhost` will refer to your laptop.
> When you are in a shell session on the lambda server, `localhost` will refer to the lambda server.
> Internally to the VPN, the lambda server's IP address is `10.253.1.15`, and so the `netcat localhost 5000` command is equivalent to `netcat 10.253.1.15 5000`.

To create a server, you will make netcat listen on a port with the `-l` flag.
Try running the command
```
$ netcat -l localhost 5000
```
You should get an error message that the port is already in use.
That's because my webserver is using this port,
and only one program at a time can use a port.

### Part 2.b: A simple chat program

You will now need a partner to continue with this lab.

> **Recall:**
> It is an academic integrity violation to work with a partner on these assignments if you are not either in class or in the QCL.

In order to create a web server, you will need to select a port that no one else is using.
The simplest way of doing that is to use your user id as the port number.
The user id is stored in the `$UID` variable of the shell and you can access it with the command
```
$ echo $UID
```
Then, you can start a server with the command
```
$ netcat -l localhost $UID
```
In a separate terminal window, use netcat to connect to your partner's server by running the command
```
$ netcat localhost <partner_uid>
```
Now every line that you type on your screen will appear on your partner's screen.
(The line will only get sent after you press enter.)

### Part 2.c: `netcat` with pipes

Like all Unix utilities, netcat can be combined together with pipes to make more complicated programs.
Run the following command
```
$ while true; do echo "hello world"; sleep 1; done | netcat -l localhost $UID
```
This outputs an infinite string of `hello world`s to netcat,
which will then deliver these strings to whoever connects.

Connect to your partner's listening netcat service by running
```
$ netcat localhost <partner_uid>
```
and observer all of the strings appear.

### Part 2.d: The web server

In order to create a web server, we need a web page to serve.
Create a file `index.html` with the following contents.
```
<html>
<body>
<strong>Insert Fun Message Here</strong>
</body>
</html>
```
Now, we'll create the server by piping this webpage to netcat in an infinite loop.
Create another file `server.sh` with the following contents.
```
#!/bin/sh
while true; do
    cat index.html | netcat -q1 -l localhost $UID
    echo "index.html served"
done
```
(The `-q1` in the `netcat` command causes netcat to close the connection after one second.
Modern web browsers maintain the connection open and send followup commands,
but our very simple web browser doesn't know how to deal with this.
So we just close the connection instead.)

Start the server.
```
$ chmod u+x server.sh
$ ./server.sh
```

> **Note:**
> Some web browsers may not render your `index.html` file properly because your web server above does not send the proper HTTP headers stating that the document is HTML and not plain text.
> You can get it to render correctly by using the following variation:
> ```
> netcat -q1 -l localhost $UID <<EOF
> HTTP/1.1 200 OK
> Content-Type: text/html
> 
> $(cat index.html)
> EOF
> ```

## Submission

In order to complete this lab, you need to enable ssh port forwarding so that you are able to connect to your partner's web server from firefox on your laptop.
Take a screenshot, and upload to sakai.
