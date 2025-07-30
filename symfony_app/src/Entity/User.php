<?php

namespace App\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class User
{
    private ?int $id = null;

    #[Assert\NotBlank]
    #[Assert\Length(min: 1, max: 100)]
    private ?string $firstName = null;

    #[Assert\NotBlank]
    #[Assert\Length(min: 1, max: 100)]
    private ?string $lastName = null;

    #[Assert\NotNull]
    private ?\DateTimeInterface $birthdate = null;

    #[Assert\NotBlank]
    #[Assert\Choice(choices: ['male', 'female'])]
    private ?string $gender = null;

    private ?\DateTimeImmutable $createdAt = null;

    private ?\DateTimeImmutable $updatedAt = null;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getFirstName(): ?string
    {
        return $this->firstName;
    }

    public function setFirstName(string $firstName): static
    {
        $this->firstName = $firstName;
        return $this;
    }

    public function getLastName(): ?string
    {
        return $this->lastName;
    }

    public function setLastName(string $lastName): static
    {
        $this->lastName = $lastName;
        return $this;
    }

    public function getBirthdate(): ?\DateTimeInterface
    {
        return $this->birthdate;
    }

    public function setBirthdate(\DateTimeInterface $birthdate): static
    {
        $this->birthdate = $birthdate;
        return $this;
    }

    public function getGender(): ?string
    {
        return $this->gender;
    }

    public function setGender(string $gender): static
    {
        $this->gender = $gender;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function setCreatedAt(\DateTimeImmutable $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getUpdatedAt(): ?\DateTimeImmutable
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(\DateTimeImmutable $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'first_name' => $this->firstName,
            'last_name' => $this->lastName,
            'birthdate' => $this->birthdate?->format('Y-m-d'),
            'gender' => $this->gender,
            'created_at' => $this->createdAt?->format('Y-m-d\TH:i:s.v\Z'),
            'updated_at' => $this->updatedAt?->format('Y-m-d\TH:i:s.v\Z'),
        ];
    }

    public static function fromArray(array $data): self
    {
        $user = new self();
        $user->id = $data['id'] ?? null;
        $user->firstName = $data['first_name'] ?? null;
        $user->lastName = $data['last_name'] ?? null;
        $user->gender = $data['gender'] ?? null;
        
        if (isset($data['birthdate'])) {
            $user->birthdate = new \DateTime($data['birthdate']);
        }
        
        if (isset($data['created_at'])) {
            $user->createdAt = new \DateTimeImmutable($data['created_at']);
        }
        
        if (isset($data['updated_at'])) {
            $user->updatedAt = new \DateTimeImmutable($data['updated_at']);
        }
        
        return $user;
    }
} 
