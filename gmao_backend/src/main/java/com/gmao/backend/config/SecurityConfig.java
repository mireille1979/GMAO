package com.gmao.backend.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final AuthenticationProvider authenticationProvider;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(org.springframework.security.config.Customizer.withDefaults())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(org.springframework.http.HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/batiments/**")
                        .hasRole("MANAGER")
                        .requestMatchers(org.springframework.http.HttpMethod.PUT, "/api/batiments/**")
                        .hasAnyRole("ADMIN", "MANAGER")
                        .requestMatchers(org.springframework.http.HttpMethod.DELETE, "/api/batiments/**")
                        .hasAnyRole("ADMIN", "MANAGER")
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/equipements/**")
                        .hasRole("MANAGER")
                        .requestMatchers(org.springframework.http.HttpMethod.PUT, "/api/equipements/**")
                        .hasAnyRole("ADMIN", "MANAGER")
                        .requestMatchers(org.springframework.http.HttpMethod.DELETE, "/api/equipements/**")
                        .hasAnyRole("ADMIN", "MANAGER")

                        .requestMatchers(org.springframework.http.HttpMethod.DELETE, "/api/equipements/**")
                        .hasAnyRole("ADMIN", "MANAGER")

                        // Stats
                        .requestMatchers("/api/stats/**").hasAnyRole("ADMIN", "MANAGER", "TECH")

                        // Planning access - MOVED UP
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/interventions/planning")
                        .hasAnyRole("ADMIN", "MANAGER", "TECH")

                        // User Management - /me endpoints first (accessible by all authenticated users)
                        .requestMatchers("/api/users/me").authenticated()
                        .requestMatchers("/api/users/me/**").authenticated()
                        .requestMatchers("/api/users/technicians").hasAnyRole("ADMIN", "MANAGER")
                        .requestMatchers("/api/users/*/affectation").hasAnyRole("ADMIN", "MANAGER")
                        .requestMatchers("/api/users/**").hasRole("ADMIN")

                        // Teams & RH
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/postes").permitAll()
                        .requestMatchers("/api/postes/**").hasAnyRole("ADMIN", "MANAGER")
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/equipes/**")
                        .hasAnyRole("ADMIN", "MANAGER", "TECH")
                        .requestMatchers("/api/equipes/**").hasAnyRole("ADMIN", "MANAGER")

                        // Absences
                        .requestMatchers("/api/absences/me").authenticated()
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/absences").authenticated()
                        .requestMatchers("/api/absences/*/statut").hasAnyRole("ADMIN", "MANAGER")
                        .requestMatchers("/api/absences/**").hasAnyRole("ADMIN", "MANAGER")

                        // Interventions
                        // Interventions
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/interventions")
                        .hasAnyRole("MANAGER", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.PATCH, "/api/interventions/*/demarrer")
                        .hasAnyRole("TECH", "MANAGER", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.PATCH, "/api/interventions/*/cloturer")
                        .hasAnyRole("TECH", "MANAGER", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/interventions/*/checklist")
                        .hasAnyRole("TECH", "MANAGER", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.PATCH, "/api/interventions/checklist/**")
                        .hasAnyRole("TECH", "MANAGER", "ADMIN")

                        // Demandes (Client requests)
                        .requestMatchers("/api/demandes/mes-demandes").hasAnyRole("CLIENT", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/demandes")
                        .hasAnyRole("CLIENT", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.PUT, "/api/demandes/*/accepter")
                        .hasAnyRole("MANAGER", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.PUT, "/api/demandes/*/refuser")
                        .hasAnyRole("MANAGER", "ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/demandes")
                        .hasAnyRole("MANAGER", "ADMIN")

                        // Notifications (tous les authentifiés)
                        .requestMatchers("/api/notifications/**").authenticated()

                        // Export (MANAGER/ADMIN)
                        .requestMatchers("/api/export/**").hasAnyRole("MANAGER", "ADMIN")

                        // Default read/list access
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/interventions/**")
                        .hasAnyRole("ADMIN", "MANAGER", "TECH")

                        .anyRequest().authenticated())
                .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authenticationProvider(authenticationProvider)
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // CORS configuration is now handled in WebConfig.java via WebMvcConfigurer
    // Spring Security will pick it up automatically via http.cors(withDefaults())
}
