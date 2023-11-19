default: patch

patch:
	./patch

test:
	./font-tester/print-quick-test

# Clean everything in .gitignore
clean:
	git clean -Xdf
