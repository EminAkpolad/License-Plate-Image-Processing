clear; clc; close all;

imageFolder = 'images'; 
imageFiles = dir(fullfile(imageFolder, '*.jpg')); 
I = imread(fullfile(imageFolder, imageFiles(1).name)); 
%Resim Renklimin kontrol et dedim%
if size(I, 3) == 3
    I = rgb2gray(I);%Eger renkliyse griye cevirdim%
end

I_double = im2double(I); %islem ypaabilmek icin binary yaptim%
I_enhanced = adapthisteq(I_double); %konstrat uyguladim%

noise01 = imnoise(I_double, 'salt & pepper', 0.01);%0.1 tuz biber gurultusu ekledim%
noise02 = imnoise(I_double, 'salt & pepper', 0.02);%burad ise 0.2 ekledim%
%ikisini ayrı ayrı yapıyorum%
h_avg = fspecial('average', [3 3]);%ortalama filtresi maskesi oluşturdum%
mean_res = imfilter(noise02, h_avg);%gürültülü resmeede uyguladım%
median_res = medfilt2(noise02, [3 3]);%medyan filtresi uyguladım%

threshold = graythresh(I_enhanced);
BW = imbinarize(I_enhanced, threshold);%resmi siyah beyaz hale getirdim%
BW_noisy = imnoise(double(BW), 'salt & pepper', 0.02); %siyah beyaz resme 0.02 gürültü ilave ettim%
BW_denoised = medfilt2(BW_noisy, [3 3]); %gürültülü resmi medyanla temizledim%

se = strel('disk', 1);%harflerdeki kopukluklar için disk oluşturdum%
BW_final = imclose(BW_denoised, se);%boşlukları kapama işlemi uyguladım%
BW_final = imfill(BW_final, 'holes');%harf ve nesnedeki boşlukları doldurdu%

stats = regionprops(BW_final > 0.5, 'Area'); %beyaz bölgeleri hesapladı%
toplamAlan = sum([stats.Area]);%tüm nesne alanları toplamı%

fprintf('--- Sonuç ---\n');
fprintf('İşlenen Dosya: %s\n', imageFiles(1).name);%islem goren dosya%
fprintf('Güzelleştirilmiş Toplam Alan: %.0f piksel\n', toplamAlan);

figure('Name', 'Görüntü İşleme Ödevi');
subplot(2,4,1); imshow(I_double); title('Orijinal (Gri)');
subplot(2,4,2); imshow(I_enhanced); title('Güzelleştirilmiş (Kontrast)');
subplot(2,4,3); imshow(noise01); title('%1 Tuz-Biber');
subplot(2,4,4); imshow(noise02); title('%2 Tuz-Biber');
subplot(2,4,5); imshow(mean_res); title('Ortalama Filtre');
subplot(2,4,6); imshow(median_res); title('Medyan Filtre');
subplot(2,4,7); imshow(BW_noisy); title('Gürültülü Binary');
subplot(2,4,8); imshow(BW_final); title('Hesaplanan Alan');