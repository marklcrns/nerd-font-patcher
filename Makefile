default: patch

patch:
	./patch

test:
	./font-tester/print-quick-test

# Clean everything in .gitignore
clean:
	sudo git clean -Xdf
