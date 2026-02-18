package com.gmao.backend.service;

import com.gmao.backend.dto.ChangePasswordRequest;
import com.gmao.backend.dto.UpdateProfileRequest;
import com.gmao.backend.entity.User;
import com.gmao.backend.entity.NotificationPreferences;
import com.gmao.backend.repository.UserRepository;
import com.gmao.backend.repository.NotificationPreferencesRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.Principal;

@Service
@RequiredArgsConstructor
public class UserService {

    private final PasswordEncoder passwordEncoder;
    private final UserRepository repository;
    private final NotificationPreferencesRepository preferencesRepository;
    private final com.gmao.backend.repository.PosteRepository posteRepository;
    private final com.gmao.backend.repository.EquipeRepository equipeRepository;

    @Transactional(readOnly = true)
    public User getConnectedUser(Principal connectedUser) {
        var principal = (User) ((UsernamePasswordAuthenticationToken) connectedUser).getPrincipal();
        // Reload from DB to ensure lazy associations are available in session
        return repository.findById(principal.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    public void changePassword(ChangePasswordRequest request, Principal connectedUser) {

        var user = (User) ((UsernamePasswordAuthenticationToken) connectedUser).getPrincipal();

        // check if the current password is correct
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new IllegalStateException("Wrong password");
        }
        // check if the two new passwords are the same
        if (!request.getNewPassword().equals(request.getConfirmationPassword())) {
            throw new IllegalStateException("Password are not the same");
        }

        // update the password
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));

        // save the new password
        repository.save(user);
    }

    public User updateProfile(UpdateProfileRequest request, Principal connectedUser) {
        var user = (User) ((UsernamePasswordAuthenticationToken) connectedUser).getPrincipal();

        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());

        return repository.save(user);
    }

    public NotificationPreferences getPreferences(Principal connectedUser) {
        var user = (User) ((UsernamePasswordAuthenticationToken) connectedUser).getPrincipal();
        return preferencesRepository.findByUserId(user.getId())
                .orElseGet(() -> {
                    // Create default preferences if not exist
                    var prefs = NotificationPreferences.builder()
                            .user(user)
                            .emailEnabled(true)
                            .pushEnabled(true)
                            .smsEnabled(false)
                            .interventionUpdates(true)
                            .generalInfo(true)
                            .build();
                    return preferencesRepository.save(prefs);
                });
    }

    public NotificationPreferences updatePreferences(NotificationPreferences newPrefs, Principal connectedUser) {
        var user = (User) ((UsernamePasswordAuthenticationToken) connectedUser).getPrincipal();
        var existingPrefs = getPreferences(connectedUser);

        existingPrefs.setEmailEnabled(newPrefs.isEmailEnabled());
        existingPrefs.setPushEnabled(newPrefs.isPushEnabled());
        existingPrefs.setSmsEnabled(newPrefs.isSmsEnabled());
        existingPrefs.setInterventionUpdates(newPrefs.isInterventionUpdates());
        existingPrefs.setGeneralInfo(newPrefs.isGeneralInfo());

        return preferencesRepository.save(existingPrefs);
    }

    public User updateUserTeamAndPoste(Long userId, Long equipeId, Long posteId) {
        User user = repository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (equipeId != null) {
            var equipe = equipeRepository.findById(equipeId)
                    .orElseThrow(() -> new RuntimeException("Equipe non trouvée"));
            user.setEquipe(equipe);
        } else {
            user.setEquipe(null);
        }

        if (posteId != null) {
            var poste = posteRepository.findById(posteId)
                    .orElseThrow(() -> new RuntimeException("Poste non trouvé"));
            user.setPoste(poste);
        } else {
            user.setPoste(null);
        }

        return repository.save(user);
    }
}
