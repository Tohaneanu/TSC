Trebuie prezenta obligatorie, instalat ubuntu si parcurse link urile de pe slack

test
1) In your shell, add your user name:
	git config --global user.name "your_username"
2) Add your email address:
	git config --global user.email "your_email_address@example.com"
3) To check the configuration, run:
	git config --global --list

4) git config --global credential.helper store

verificare daca mai cere parola
5) ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
test