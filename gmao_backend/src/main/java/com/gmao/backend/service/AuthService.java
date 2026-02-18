package com.gmao.backend.service;

import com.gmao.backend.config.JwtService;
import com.gmao.backend.dto.AuthenticationRequest;
import com.gmao.backend.dto.AuthenticationResponse;
import com.gmao.backend.dto.RegisterRequest;
import com.gmao.backend.entity.User;
import com.gmao.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.gmao.backend.entity.PasswordResetToken;
import com.gmao.backend.repository.PasswordResetTokenRepository;
import java.time.LocalDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

        private final UserRepository repository;
        private final PasswordEncoder passwordEncoder;
        private final JwtService jwtService;
        private final AuthenticationManager authenticationManager;
        private final PasswordResetTokenRepository tokenRepository;
        private final com.gmao.backend.repository.PosteRepository posteRepository;

        public AuthenticationResponse register(RegisterRequest request) {
                var userBuilder = User.builder()
                                .firstName(request.getFirstName())
                                .lastName(request.getLastName())
                                .email(request.getEmail())
                                .password(passwordEncoder.encode(request.getPassword()))
                                .role(request.getRole())
                                .telephone(request.getTelephone())
                                .specialite(request.getSpecialite())
                                .isActive(request.getRole() == com.gmao.backend.entity.Role.CLIENT
                                                || request.getRole() == com.gmao.backend.entity.Role.TECH);

                if (request.getPosteId() != null) {
                        var poste = posteRepository.findById(request.getPosteId())
                                        .orElseThrow(() -> new RuntimeException("Poste non trouvé"));
                        userBuilder.poste(poste);
                }

                var user = userBuilder.build();
                repository.save(user);
                var jwtToken = jwtService.generateToken(user);
                return AuthenticationResponse.builder()
                                .token(jwtToken)
                                .id(user.getId())
                                .role(user.getRole())
                                .firstName(user.getFirstName())
                                .lastName(user.getLastName())
                                .build();
        }

        public AuthenticationResponse authenticate(AuthenticationRequest request) {
                authenticationManager.authenticate(
                                new UsernamePasswordAuthenticationToken(
                                                request.getEmail(),
                                                request.getPassword()));
                var user = repository.findByEmail(request.getEmail())
                                .orElseThrow();
                var jwtToken = jwtService.generateToken(user);
                return AuthenticationResponse.builder()
                                .token(jwtToken)
                                .id(user.getId())
                                .role(user.getRole())
                                .firstName(user.getFirstName())
                                .lastName(user.getLastName())
                                .build();
        }

        public void forgotPassword(String email) {
                var user = repository.findByEmail(email)
                                .orElseThrow(() -> new RuntimeException("User not found"));

                // Generate Token
                String token = UUID.randomUUID().toString();
                PasswordResetToken resetToken = PasswordResetToken.builder()
                                .token(token)
                                .user(user)
                                .expiryDate(LocalDateTime.now().plusHours(1))
                                .build();

                tokenRepository.save(resetToken);

                // SIMULATE EMAIL SENDING
                System.out.println("------------------------------------------------");
                System.out.println("PASSWORD RESET REQUEST FOR: " + email);
                System.out.println("TOKEN: " + token);
                System.out.println("------------------------------------------------");
        }

        public void resetPassword(String token, String newPassword) {
                PasswordResetToken resetToken = tokenRepository.findByToken(token)
                                .orElseThrow(() -> new RuntimeException("Invalid token"));

                if (resetToken.isExpired()) {
                        throw new RuntimeException("Token expired");
                }

                User user = resetToken.getUser();
                user.setPassword(passwordEncoder.encode(newPassword));
                repository.save(user);

                tokenRepository.delete(resetToken);
        }
}
