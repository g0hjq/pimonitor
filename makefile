# Compiler and flags
CC = gcc
CFLAGS = -Wall -g
LDFLAGS =

# Source files and output
SRC = pimonitor.c
OBJ = $(SRC:.c=.o)
TARGET = pimonitor

# Installation paths
BINDIR = /usr/local/bin
SERVICEDIR = /etc/systemd/system
SERVICEFILE = pimonitor.service

# Default target
all: $(TARGET)

# Compile the program
$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Install the program to /usr/local/bin
install: $(TARGET)
	install -d $(BINDIR)
	install -m 755 $(TARGET) $(BINDIR)
	@echo "Installed $(TARGET) to $(BINDIR)"
	

# Create the systemd service file
$(SERVICEFILE):
	@echo "[Unit]" > $(SERVICEFILE)
	@echo "Description=PiMonitor Service" >> $(SERVICEFILE)
	@echo "After=network-online.target" >> $(SERVICEFILE)
	@echo "Wants=network-online.target" >> $(SERVICEFILE)
	@echo "" >> $(SERVICEFILE)
	@echo "[Service]" >> $(SERVICEFILE)
	@echo "ExecStart=$(BINDIR)/$(TARGET)" >> $(SERVICEFILE)
	@echo "Restart=always" >> $(SERVICEFILE)
	@echo "RestartSec=5" >> $(SERVICEFILE)
	@echo "" >> $(SERVICEFILE)
	@echo "[Install]" >> $(SERVICEFILE)
	@echo "WantedBy=multi-user.target" >> $(SERVICEFILE)

# Install the systemd service
install-service: install $(SERVICEFILE)
	install -d $(SERVICEDIR)
	install -m 644 $(SERVICEFILE) $(SERVICEDIR)
	systemctl daemon-reload
	systemctl enable $(SERVICEFILE)
	systemctl start $(SERVICEFILE)
	@echo "Installed and enabled $(SERVICEFILE)"

# Uninstall the program and service
uninstall:
	-systemctl stop $(SERVICEFILE)
	-systemctl disable $(SERVICEFILE)
	rm -f $(SERVICEDIR)/$(SERVICEFILE)
	rm -f $(BINDIR)/$(TARGET)
	systemctl daemon-reload
	@echo "Uninstalled $(TARGET) and $(SERVICEFILE)"

# Clean up
clean:
	rm -f $(OBJ) $(TARGET) $(SERVICEFILE)

# Phony targets
.PHONY: all clean install install-service uninstall

