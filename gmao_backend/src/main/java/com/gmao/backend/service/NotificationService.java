package com.gmao.backend.service;

import com.gmao.backend.entity.Notification;
import com.gmao.backend.entity.TypeNotification;
import com.gmao.backend.entity.User;
import com.gmao.backend.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository repository;

    @Transactional(readOnly = true)
    public List<Notification> getForUser(Long userId) {
        return repository.findByDestinataire_IdOrderByDateCreationDesc(userId);
    }

    @Transactional(readOnly = true)
    public long countUnread(Long userId) {
        return repository.countByDestinataire_IdAndLuFalse(userId);
    }

    @Transactional
    public Notification markAsRead(Long id) {
        Notification n = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notification introuvable"));
        n.setLu(true);
        return repository.save(n);
    }

    @Transactional
    public void markAllAsRead(Long userId) {
        List<Notification> unread = repository.findByDestinataire_IdOrderByDateCreationDesc(userId);
        for (Notification n : unread) {
            if (!n.isLu()) {
                n.setLu(true);
                repository.save(n);
            }
        }
    }

    @Transactional
    public Notification create(User destinataire, String message, TypeNotification type) {
        Notification n = Notification.builder()
                .destinataire(destinataire)
                .message(message)
                .type(type)
                .build();
        return repository.save(n);
    }
}
