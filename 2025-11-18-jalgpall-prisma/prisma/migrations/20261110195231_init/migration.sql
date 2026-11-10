-- CreateTable
CREATE TABLE `Country` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(60) NOT NULL,
    `code` VARCHAR(3) NOT NULL,
    `createdat` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `Country_code_key`(`code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Club` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `location` VARCHAR(60) NOT NULL,
    `name` VARCHAR(80) NOT NULL,
    `stadium` VARCHAR(80) NOT NULL,
    `createdat` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `Club_name_key`(`name`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Player` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `firstname` VARCHAR(50) NOT NULL,
    `lastname` VARCHAR(50) NOT NULL,
    `salary` DECIMAL(10, 2) NOT NULL,
    `countryid` INTEGER NOT NULL,
    `clubid` INTEGER NOT NULL,
    `createdat` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Player_clubid_idx`(`clubid`),
    INDEX `Player_countryid_idx`(`countryid`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Coach` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `firstname` VARCHAR(50) NOT NULL,
    `lastname` VARCHAR(50) NOT NULL,
    `countryid` INTEGER NOT NULL,
    `createdat` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Coach_countryid_idx`(`countryid`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `CoachClub` (
    `coachid` INTEGER NOT NULL,
    `clubid` INTEGER NOT NULL,
    `role` VARCHAR(40) NOT NULL DEFAULT 'peatreener',
    `createdat` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `CoachClub_clubid_idx`(`clubid`),
    PRIMARY KEY (`coachid`, `clubid`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Game` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `homeclub` INTEGER NOT NULL,
    `foreignclub` INTEGER NOT NULL,
    `homescore` INTEGER NOT NULL,
    `foreignscore` INTEGER NOT NULL,
    `homeformation` VARCHAR(20) NOT NULL,
    `foreignformation` VARCHAR(20) NOT NULL,
    `gametime` DATETIME(3) NOT NULL,
    `createdat` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Game_homeclub_idx`(`homeclub`),
    INDEX `Game_foreignclub_idx`(`foreignclub`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `Player` ADD CONSTRAINT `Player_countryid_fkey` FOREIGN KEY (`countryid`) REFERENCES `Country`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Player` ADD CONSTRAINT `Player_clubid_fkey` FOREIGN KEY (`clubid`) REFERENCES `Club`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Coach` ADD CONSTRAINT `Coach_countryid_fkey` FOREIGN KEY (`countryid`) REFERENCES `Country`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `CoachClub` ADD CONSTRAINT `CoachClub_coachid_fkey` FOREIGN KEY (`coachid`) REFERENCES `Coach`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `CoachClub` ADD CONSTRAINT `CoachClub_clubid_fkey` FOREIGN KEY (`clubid`) REFERENCES `Club`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Game` ADD CONSTRAINT `Game_homeclub_fkey` FOREIGN KEY (`homeclub`) REFERENCES `Club`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Game` ADD CONSTRAINT `Game_foreignclub_fkey` FOREIGN KEY (`foreignclub`) REFERENCES `Club`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
