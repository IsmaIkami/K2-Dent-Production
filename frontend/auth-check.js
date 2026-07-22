/**
 * DentalCockpit Pro - Authentication Check
 * Vérifie l'authentification avant d'accéder aux pages protégées
 */

(function() {
    'use strict';

    // Petit délai pour laisser le temps à la session d'être disponible
    setTimeout(function() {
        // Vérifier si l'utilisateur est authentifié
        const isAuthenticated = sessionStorage.getItem('dental_authenticated') === 'true';
        const loginTime = sessionStorage.getItem('dental_login_time');

        // Session expire après 8 heures
        const SESSION_DURATION = 8 * 60 * 60 * 1000; // 8 heures en millisecondes

        if (!isAuthenticated) {
            // Pas authentifié - rediriger vers la page de connexion
            window.location.href = '/K2-Dent-Production/login.html';
            return;
        }

    if (loginTime) {
        const loginDate = new Date(loginTime);
        const now = new Date();
        const elapsed = now - loginDate;

        if (elapsed > SESSION_DURATION) {
            // Session expirée
            sessionStorage.clear();
            alert('⏰ Votre session a expiré. Veuillez vous reconnecter.');
            window.location.href = '/K2-Dent-Production/login.html';
            return;
        }
    }

    // Ajouter un indicateur visuel de l'utilisateur connecté
    const currentUser = sessionStorage.getItem('dental_user');
    if (currentUser) {
        console.log('✅ Utilisateur connecté:', currentUser);
    }

    // Ajouter un bouton de déconnexion dans la navigation
    document.addEventListener('DOMContentLoaded', function() {
        // Trouver le container d'actions dans le topbar
        const topbarActions = document.querySelector('.topbar-actions');
        if (topbarActions) {
            // Créer le bouton de déconnexion
            const logoutBtn = document.createElement('div');
            logoutBtn.className = 'icon-btn';
            logoutBtn.innerHTML = '🚪';
            logoutBtn.title = 'Déconnexion';
            logoutBtn.style.cursor = 'pointer';
            logoutBtn.onclick = function() {
                if (confirm('Êtes-vous sûr de vouloir vous déconnecter ?')) {
                    sessionStorage.clear();
                    window.location.href = '/K2-Dent-Production/login.html';
                }
            };
            topbarActions.appendChild(logoutBtn);
        }
    });
    }, 100); // Délai de 100ms
})();
