new Vue({
    el: '#app',
    data: {
        showMenu: false,
        selectedSection: 'dashboard',
        totalPlayers: 100,
        activeCheaters: 3,
        serverUptime: '72 hours',
        peakPlayers: 150,
        searchQuery: '',
        banSearchQuery: '',
        showModal: false,
        modalBan: {},
        showScreenshotModal: false,
        modalScreenshot: '',
        players: [
            { id: 1, name: 'John Doe', steamId: 'STEAM_0:1:12345678', ping: 50 },
        ],
        bans: [
            { id: 1, name: "Jane Smith", reason: "Abusive language", steam: "STEAM_0:1:87654321", discord: "Jane#1234", hwid1: "HWID123456", ip: "192.168.1.100", expire: "Permanent" },
        ],
        selectedPlayer: null,
        playerOptions: [
            { name: 'ESP', enabled: false, type: 'toggle', category: 'misc' },
            { name: 'Player Names', enabled: false, type: 'toggle', category: 'misc' },
            { name: 'God Mode', enabled: false, type: 'toggle', category: 'admin' },
            { name: 'No Clip', enabled: false, type: 'toggle', category: 'admin' },
            { name: 'Invisibility', enabled: false, type: 'toggle', category: 'misc' },
            { name: 'Bones', enabled: false, type: 'toggle', category: 'misc' },
            { name: 'Repair Vehicle', enabled: false, type: 'button', category: 'admin' },
            { name: 'Teleport', enabled: false, type: 'button', category: 'admin' }
        ],
        lastUpdates: [
            { id: 1, title: "Update 1", description: "Resolved server lag issues to enhance performance.", date: "2025-01-01" },
        ],
        serverOptions: [
            { name: 'Restart Server', action: 'restart' },
            { name: 'Shutdown Server', action: 'shutdown' },
            { name: 'Clear Cache', action: 'clear_cache' },
            { name: 'Update Scripts', action: 'update_scripts' },
            { name: 'Backup Database', action: 'backup_database' },
        ],
        logs: [
        ],
        settings: {
            notifications: true,
            theme: 'dark',
            textScale: 100,
            iconScale: 100,
            fontStyle: 'sans-serif',
            iconTheme: 'font-awesome'
        },
        vehicleName: '',
        showObjectSpawner: false,
        spawnObject: '',
        objectName: '',
        pedModel: '',
        notifications: [],
        notificationId: 0,
        latestBans: [
            { id: 1, name: 'Jane Smith', reason: 'Abusive language', timestamp: '2025-01-01' },
        ],
        showPlayerDetailsModal: false,
        selectedPlayerDetails: null,
        playerDetails: {
            health: 100,
            armor: 75,
            cash: 5000,
            bank: 50000,
            job: 'Police',
            jobRank: 'Officer',
            gang: 'None',
            gangRank: 'None',
            citizenid: 'ABC123',
            license: 'license:1234567',
            playTime: '12h 34m'  
        },
        permissionGroups: [
            {
                id: 1,
                name: "Super Admin",
                permissions: ["all", "ban", "kick", "teleport", "spawn", "money"]
            },
            {
                id: 2,
                name: "Admin",
                permissions: ["ban", "kick", "teleport", "spawn"]
            },
            {
                id: 3,
                name: "Moderator",
                permissions: ["kick", "teleport"]
            }
        ],
        adminList: [
            {
                id: 1,
                name: "John Admin",
                avatar: "https://i.imgur.com/example1.jpg",
                group: "Super Admin",
                permissions: ["all"]
            },
            {
                id: 2,
                name: "Jane Mod",
                avatar: "https://i.imgur.com/example2.jpg",
                group: "Moderator",
                permissions: ["kick", "teleport", "spawn"]
            }
        ],
        showGroupModal: false,
        showAdminModal: false,
        editingGroup: null,
        selectedAdmin: null,
        groupForm: {
            name: '',
            permissions: []
        },
        adminForm: {
            group: '',
            permissions: []
        },
        availablePermissions: [
            { id: 1, name: 'ban', description: 'Can ban players' },
            { id: 2, name: 'kick', description: 'Can kick players' },
            { id: 3, name: 'teleport', description: 'Can teleport players' },
            { id: 4, name: 'spawn', description: 'Can spawn vehicles/items' },
            { id: 5, name: 'money', description: 'Can manage player money' },
            { id: 6, name: 'god', description: 'Has god mode access' },
            { id: 7, name: 'noclip', description: 'Can use noclip' },
            { id: 8, name: 'spectate', description: 'Can spectate players' }
        ],
        activeTab: 'groups',
        groupSearch: '',
        adminSearch: '',
        selectedGroupFilter: '',
    },
    methods: {
        showPlayerDetails(player) {
            this.selectedPlayerDetails = player;
            this.showPlayerDetailsModal = true;
        },
        closePlayerDetails() {
            this.showPlayerDetailsModal = false;
            this.selectedPlayerDetails = null;
        },

        updatePlayerJob(newJob) {
            if (this.selectedPlayerDetails) {
                fetch(`https://${GetParentResourceName()}/updatePlayerJob`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ playerId: this.selectedPlayerDetails.id, newJob: newJob })
                })
                .then(response => response.json())
                .then(data => {
                    this.showNotification(`Job updated to ${newJob}`, 'success');
                }).catch(error => {
                    this.showNotification(`Failed to update job`, 'error');
                });
            }
        },
        updatePlayerGang(newGang) {
            if (this.selectedPlayerDetails) {
                fetch(`https://${GetParentResourceName()}/updatePlayerGang`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ playerId: this.selectedPlayerDetails.id, newGang: newGang })
                })
                .then(response => response.json())
                .then(data => {
                    this.showNotification(`Gang updated to ${newGang}`, 'success');
                }).catch(error => {
                    this.showNotification(`Failed to update gang`, 'error');
                });
            }
        },
        givePlayerMoney(amount) {
            if (this.selectedPlayerDetails) {
                fetch(`https://${GetParentResourceName()}/givePlayerMoney`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ playerId: this.selectedPlayerDetails.id, amount: amount })
                })
                .then(response => response.json())
                .then(data => {
                    this.showNotification(`Gave $${amount} to player`, 'success');
                }).catch(error => {
                    this.showNotification(`Failed to give money`, 'error');
                });
            }
        },
        removePlayerMoney(amount) {
            if (this.selectedPlayerDetails) {
                fetch(`https://${GetParentResourceName()}/removePlayerMoney`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ playerId: this.selectedPlayerDetails.id, amount: amount })
                })
                .then(response => response.json())
                .then(data => {
                    this.showNotification(`Removed $${amount} from player`, 'success');
                }).catch(error => {
                    this.showNotification(`Failed to remove money`, 'error');
                });
            }
        },
        jailPlayer(time) {
            if (this.selectedPlayerDetails) {
                fetch(`https://${GetParentResourceName()}/jailPlayer`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ playerId: this.selectedPlayerDetails.id, time: time })
                })
                .then(response => response.json())
                .then(data => {
                    this.showNotification(`Player jailed for ${time} minutes`, 'success');
                }).catch(error => {
                    this.showNotification(`Failed to jail player`, 'error');
                });
            }
        },
        cuffPlayer() {
            if (this.selectedPlayerDetails) {
                fetch(`https://${GetParentResourceName()}/cuffPlayer`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ playerId: this.selectedPlayerDetails.id })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        this.showNotification(`Player cuffed successfully`, 'success');
                    } else {
                        this.showNotification(`Failed to cuff player`, 'error');
                    }
                }).catch(error => {
                    console.error('Error cuffing player:', error);
                    this.showNotification(`Error cuffing player`, 'error');
                });
            }
        },

        showNotification(message, type = 'info') {
            const id = Date.now();
            this.notifications.push({ id, message, type });
            setTimeout(() => {
                this.removeNotification(id);
            }, 4000);
        },
        removeNotification(id) {
            const index = this.notifications.findIndex(n => n.id === id);
            if (index > -1) {
                this.notifications.splice(index, 1);
            }
        },

        updateStyles() {
            document.documentElement.style.setProperty('--text-scale', `${this.settings.textScale}%`);
            document.documentElement.style.setProperty('--icon-scale', `${this.settings.iconScale}%`);
        },
        decreaseTextScale() {
            this.settings.textScale = Math.max(this.settings.textScale - 10, 50);
            this.updateStyles();
        },
        increaseTextScale() {
            this.settings.textScale = Math.min(this.settings.textScale + 10, 150);
            this.updateStyles();
        },
        decreaseIconScale() {
            this.settings.iconScale = Math.max(this.settings.iconScale - 10, 50);
            this.updateStyles();
        },
        increaseIconScale() {
            this.settings.iconScale = Math.min(this.settings.iconScale + 10, 150);
            this.updateStyles();
        },
        applyTheme(theme) {
            document.documentElement.classList.remove('light-mode', 'dark-mode');

            if (theme === 'light') {
                document.documentElement.classList.add('light-mode');
            } else if (theme === 'dark') {
                document.documentElement.classList.add('dark-mode');
            } else if (theme === 'auto') {
                const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                if (prefersDark) {
                    document.documentElement.classList.add('dark-mode');
                } else {
                    document.documentElement.classList.add('light-mode');
                }
            }
        },
        toggleTheme() {
            this.applyTheme(this.settings.theme);
            localStorage.setItem('theme', this.settings.theme);
        },

        applyFontStyle() {
            document.body.style.fontFamily = this.settings.fontStyle; 
            localStorage.setItem('fontStyle', this.settings.fontStyle); 
        },
        applyIconLibrary() {
            this.$forceUpdate(); 
            localStorage.setItem('iconTheme', this.settings.iconTheme); 
        },
        fetchDashboardStats() {
            fetch(`https://${GetParentResourceName()}/getDashboardStats`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})  
            })
            .then(response => response.json())
            .then(data => {
                this.totalPlayers   = data.totalPlayers;
                this.activeCheaters = data.activeCheaters;
                this.serverUptime   = data.serverUptime;
                this.peakPlayers    = data.peakPlayers;
            })
            .catch(error => {
                console.error('Error fetching dashboard stats:', error);
            });

        },
        fetchPlayers() {
            fetch(`https://${GetParentResourceName()}/getPlayers`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            })
            .then(response => response.json())
            .then(data => {
                this.players = data.players;
            })
            .catch(error => {
                console.error('Error fetching players:', error);
            });
        },
        kickPlayer(playerId) {
            fetch(`https://${GetParentResourceName()}/kickPlayer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ playerId: playerId })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.showNotification(`Player ${playerId} kicked successfully`, 'success');
                    this.fetchPlayers();
                } else {
                    this.showNotification(`Failed to kick player ${playerId}`, 'error');
                }
            })
            .catch(error => {
                console.error('Error kicking player:', error);
                this.showNotification(`Error kicking player ${playerId}`, 'error');
            });
        },
        banPlayer(playerId) {
            fetch(`https://${GetParentResourceName()}/banPlayer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ playerId: playerId })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.showNotification(`Player ${playerId} banned successfully`, 'success');
                    this.fetchPlayers();
                } else {
                    this.showNotification(`Failed to ban player ${playerId}`, 'error');
                }
            })
            .catch(error => {
                console.error('Error banning player:', error);
                this.showNotification(`Error banning player ${playerId}`, 'error');
            });
        },
        spectatePlayer(playerId) {
            fetch(`https://${GetParentResourceName()}/spectatePlayer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ playerId: playerId })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.showNotification(`Spectating player ${playerId}`, 'success');
                } else {
                    this.showNotification(`Failed to spectate player ${playerId}`, 'error');
                }
            })
            .catch(error => {
                console.error('Error spectating player:', error);
                this.showNotification(`Error spectating player ${playerId}`, 'error');
            });
        },
        fetchBans() {
            fetch('/bans.json')
                .then(response => response.json())
                .then(data => {
                    this.bans = data;
                })
                .catch(error => {
                    console.error('Error fetching bans:', error);
                });
        },
        unbanPlayer(banId) {
            fetch(`https://${GetParentResourceName()}/unbanPlayer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ banId: banId })
            }).then(response => {
                if (response.ok) {
                    this.bans = this.bans.filter(ban => ban.id !== banId);
                    this.showNotification(`Player with ID ${banId} unbanned successfully`, 'success');
                } else {
                    this.showNotification(`Failed to unban player with ID ${banId}`, 'error');
                }
            }).catch(error => {
                console.error('Error unbanning player:', error);
                this.showNotification(`Error unbanning player with ID ${banId}`, 'error');
            });
        },
        selectSection(section) {
            this.selectedSection = section;
        },
        screenshotPlayer(playerId) {
            fetch(`https://${GetParentResourceName()}/screenshotPlayer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ playerId })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.showNotification(`Screenshot request sent for player ${playerId}.`, 'success');
                } else {
                    this.showNotification(`Failed to send screenshot request for player ${playerId}.`, 'error');
                }
            })
            .catch(error => {
                console.error('Error taking screenshot:', error);
                this.showNotification('Error sending screenshot request.', 'error');
            });
        },        
        closeScreenshotModal() {
            this.showScreenshotModal = false;
            this.modalScreenshot = null;
        },
        showBanInfo(ban) {
            this.modalBan = ban;
            this.showModal = true;
        },
        closeModal() {
            this.showModal = false;
            this.modalBan = {};
        },
        objectSpawn() {
            this.showNotification(`Spawning object: ${this.objectName}`, 'success');
            this.objectName = '';
        },
        changePed() {
            this.showNotification(`Changing ped model to: ${this.pedModel}`, 'success');
            this.pedModel = '';
        },
        spawnVehicle() {
            this.showNotification(`Spawning vehicle: ${this.vehicleName}`, 'success');
            this.vehicleName = '';
        },
        openObjectSpawner() {
            this.showObjectSpawner = true;
        },
        closeObjectSpawner() {
            this.showObjectSpawner = false;
            this.spawnObject = '';
        },
        spawnObjectAction() {
            this.showNotification(`Spawning object: ${this.spawnObject}`, 'success');
            this.closeObjectSpawner();
        },
        deleteAllVehicles() {
            this.showNotification('Deleting all vehicles', 'success');
        },
        toggleOptiona(option) {
            const enabled = this.playerOptions.find(o => o.name === option).enabled;
            fetch(`https://${GetParentResourceName()}/toggleOptiona`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ option, enabled })
            });
        },

        getNotificationIcon(type) {
            const icons = {
                success: 'fas fa-check',
                error: 'fas fa-exclamation',
                warning: 'fas fa-bell',
                info: 'fas fa-info'
            };
            return icons[type] || 'fas fa-bell';
        },
        copyToClipboard(text) {
            navigator.clipboard.writeText(text).then(() => {
                this.showNotification('Copied to clipboard', 'success');
            }).catch(() => {
                this.showNotification('Failed to copy to clipboard', 'error');
            });
        },
        showNotification(message, type = 'info') {
            const id = Date.now();
            this.notifications.push({ id, message, type });
            
            setTimeout(() => {
                this.removeNotification(id);
            }, 4000);
        },

        removeNotification(id) {
            const index = this.notifications.findIndex(n => n.id === id);
            if (index > -1) {
                this.notifications.splice(index, 1);
            }
        },

        updateStats(stats) {
            this.totalPlayers = stats.totalPlayers;
            this.activeCheaters =  stats.activeCheaters;
            this.serverUptime = stats.serverUptime;
            this.peakPlayers = stats.peakPlayers;
        },
        executeServerOption(action) {
            fetch(`https://${GetParentResourceName()}/executeServerOption`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action }) 
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.showNotification(`Executing server action: ${action}`, 'success');
                } else {
                    this.showNotification('Failed to execute server action.', 'error');
                }
            })
            .catch(error => {
                console.error('Error executing server action:', error);
                this.showNotification('Error executing server action.', 'error');
            });
        },        
        clearAllEntities() {
            this.showNotification('Clearing all entities', 'success');
            fetch(`https://${GetParentResourceName()}/clearAllEntities`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        },
        getLogIcon(type) {
            switch (type) {
                case 'error':
                    return 'fa-times-circle log-icon error';
                case 'warning':
                    return 'fa-exclamation-circle log-icon warning';
                case 'success':
                    return 'fa-check-circle log-icon success';
                default:
                    return 'fa-info-circle log-icon';
            }
        },
        getOptionIcon(optionName) {
            const icons = {
                'Restart Server': 'fas fa-sync',
                'Shutdown Server': 'fas fa-power-off',
                'Clear Cache': 'fas fa-broom',
                'Update Scripts': 'fas fa-code',
                'Backup Database': 'fas fa-database',
            };
            return icons[optionName] || 'fas fa-cog';
        },
        showScreenshot(data) {
            this.modalScreenshot = data.imageUrl;
            this.showScreenshotModal = true;
        },
        handleKeydown(event) {
            if (event.key === 'Escape') {
                if (this.showScreenshotModal) {
                    this.closeScreenshotModal();
                } else if (this.showMenu) {
                    this.showMenu = false;
                    fetch(`https://${GetParentResourceName()}/close`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({})
                    });
                }
            }
        },
        createNewGroup() {
            this.editingGroup = null;
            this.groupForm = {
                name: '',
                permissions: []
            };
            this.showGroupModal = true;
        },
        editGroup(group) {
            this.editingGroup = group;
            this.groupForm = {
                name: group.name,
                permissions: [...group.permissions]
            };
            this.showGroupModal = true;
        },
        closeGroupModal() {
            this.showGroupModal = false;
            this.editingGroup = null;
            this.groupForm = { name: '', permissions: [] };
        },
        saveGroup() {
            if (this.editingGroup) {
                const index = this.permissionGroups.findIndex(g => g.id === this.editingGroup.id);
                if (index !== -1) {
                    this.permissionGroups[index] = {
                        ...this.editingGroup,
                        name: this.groupForm.name,
                        permissions: this.groupForm.permissions
                    };
                }
            } else {
                this.permissionGroups.push({
                    id: Date.now(),
                    name: this.groupForm.name,
                    permissions: this.groupForm.permissions
                });
            }
            this.closeGroupModal();
        },
        editAdminPerms(admin) {
            this.selectedAdmin = admin;
            this.adminForm = {
                group: admin.group,
                permissions: [...admin.permissions]
            };
            this.showAdminModal = true;
        },
        closeAdminModal() {
            this.showAdminModal = false;
            this.selectedAdmin = null;
            this.adminForm = { group: '', permissions: [] };
        },
        saveAdminPerms() {
            if (this.selectedAdmin) {
                const index = this.adminList.findIndex(a => a.id === this.selectedAdmin.id);
                if (index !== -1) {
                    this.adminList[index] = {
                        ...this.selectedAdmin,
                        group: this.adminForm.group,
                        permissions: this.adminForm.permissions
                    };
                }
            }
            this.closeAdminModal();
        },
        addNewAdmin() {
            this.showAdminModal = true;
            this.selectedAdmin = null;
            this.adminForm = {
                name: '',
                group: '',
                permissions: []
            };
        },
        
        resetAdminPerms(admin) {
            if (confirm(`Reset permissions for ${admin.name}?`)) {
                const group = this.permissionGroups.find(g => g.name === admin.group);
                if (group) {
                    admin.permissions = [...group.permissions];
                    this.showNotification('Permissions reset to group defaults', 'success');
                }
            }
        },
        
        removeAdmin(admin) {
            if (confirm(`Remove admin status from ${admin.name}?`)) {
                const index = this.adminList.findIndex(a => a.id === admin.id);
                if (index !== -1) {
                    this.adminList.splice(index, 1);
                    this.showNotification('Admin removed successfully', 'success');
                }
            }
        }
    },
    computed: {
        filteredPlayers() {
            return this.players.filter(player => player.name.toLowerCase().includes(this.searchQuery.toLowerCase()));
        },
        filteredBans() {
            return this.bans.filter(ban => ban.name.toLowerCase().includes(this.banSearchQuery.toLowerCase()));
        },
        filteredGroups() {
            if (!this.groupSearch) return this.permissionGroups;
            return this.permissionGroups.filter(group => 
                group.name.toLowerCase().includes(this.groupSearch.toLowerCase())
            );
        },
        filteredAdmins() {
            return this.adminList.filter(admin => {
                const matchesSearch = !this.adminSearch || 
                    admin.name.toLowerCase().includes(this.adminSearch.toLowerCase());
                const matchesGroup = !this.selectedGroupFilter || 
                    admin.group === this.selectedGroupFilter;
                return matchesSearch && matchesGroup;
            });
        }
    },
    mounted() {
        const savedFontStyle = localStorage.getItem('fontStyle') || 'sans-serif';
        this.settings.fontStyle = savedFontStyle;
        document.body.style.fontFamily = savedFontStyle;
        const savedTheme = localStorage.getItem('iconTheme') || 'font-awesome';
        this.settings.iconTheme = savedTheme;
        window.addEventListener('message', (event) => {
            let action = event.data.action;
            switch (action) {
                case "open":
                    this.fetchBans();
                    this.fetchPlayers();
                    this.fetchDashboardStats();
                    this.showMenu = true;
                    break;
                case "close":
                    this.showMenu = false;
                    break;
                case "dashboardStats":
                    this.totalPlayers   = event.data.totalPlayers;
                    this.activeCheaters = event.data.activeCheaters;
                    this.serverUptime   = event.data.serverUptime;
                    this.peakPlayers    = event.data.peakPlayers;
                    break;
                case "players":
                    this.players = event.data.players;
                    break;
                case "displayScreenshot":
                    this.modalScreenshot = event.data.imageUrl;
                    this.showScreenshotModal = true;
                    break;
            }
        });
        window.addEventListener('keydown', this.handleKeydown);
    },
    beforeDestroy() {
        window.removeEventListener('keydown', this.handleKeydown);
    }
});
