package com.gmao.backend.controller;

import com.gmao.backend.entity.User;
import com.gmao.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.gmao.backend.dto.ChangePasswordRequest;
import com.gmao.backend.dto.UpdateProfileRequest;
import com.gmao.backend.entity.NotificationPreferences;
import com.gmao.backend.service.UserService;
import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository repository;
    private final UserService service;

    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(repository.findAll());
    }

    @GetMapping("/technicians")
    public ResponseEntity<List<User>> getTechnicians() {
        return ResponseEntity.ok(repository.findByRole(com.gmao.backend.entity.Role.TECH));
    }

    @PatchMapping("/{id}/validate")
    public ResponseEntity<User> validateUser(@PathVariable Long id) {
        return repository.findById(id)
                .map(user -> {
                    user.setIsActive(true);
                    return ResponseEntity.ok(repository.save(user));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PatchMapping("/me/password")
    public ResponseEntity<?> changePassword(
            @RequestBody ChangePasswordRequest request,
            Principal connectedUser) {
        service.changePassword(request, connectedUser);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<User> getProfile(Principal connectedUser) {
        return ResponseEntity.ok(service.getConnectedUser(connectedUser));
    }

    @PutMapping("/me")
    public ResponseEntity<User> updateProfile(
            @RequestBody UpdateProfileRequest request,
            Principal connectedUser) {
        return ResponseEntity.ok(service.updateProfile(request, connectedUser));
    }

    @GetMapping("/me/preferences")
    public ResponseEntity<NotificationPreferences> getPreferences(Principal connectedUser) {
        return ResponseEntity.ok(service.getPreferences(connectedUser));
    }

    @PutMapping("/me/preferences")
    public ResponseEntity<NotificationPreferences> updatePreferences(
            @RequestBody NotificationPreferences preferences,
            Principal connectedUser) {
        return ResponseEntity.ok(service.updatePreferences(preferences, connectedUser));
    }

    @PatchMapping("/{id}/affectation")
    public ResponseEntity<User> assignUser(
            @PathVariable Long id,
            @RequestBody com.gmao.backend.dto.UserAssignmentRequest request) {
        return ResponseEntity.ok(service.updateUserTeamAndPoste(id, request.getEquipeId(), request.getPosteId()));
    }
}
